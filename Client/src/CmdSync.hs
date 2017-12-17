-----------------------------------------------------------------------------
-- Nubo Client Application
-- Copyright (c) 2017, Pascal Levy
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-----------------------------------------------------------------------------

module CmdSync (
      cmdSync
    , helpSync
) where

import qualified Data.ByteString as B
import Control.Monad (forM, forM_)
import Control.Monad.Trans (liftIO)
import Control.Monad.Reader (ask)
import Data.Text.Encoding (encodeUtf8)
import Data.List (sortBy, partition, isPrefixOf)
import System.FilePath (makeRelative, combine)
import Data.Either (rights)
import PrettyPrint
import Config
import Misc
import Error
import MsgPack
import Database
import FileHelper
import WebService
import Matching
import CmdSync.Logic
import CmdSync.Actions

-----------------------------------------------------------------------------

-- | Parse arguments for the 'sync' command.
--
cmdSync :: [String] -> IO ExitStatus
cmdSync args = case parseArgs args [OptionDry, OptionTheirs, OptionOurs] of
    Left err            -> putErr err >> 
                           return StatusInvalidCommand
    Right (opts, files) -> case priority opts of
                               Left err -> putErr err >> 
                                           return StatusInvalidCommand
                               Right p  -> newEnvTLS >>= \env ->
                                           openDBAndRun env (doSync (OptionDry `elem` opts) p files)
    where
        priority :: [Option] -> Either Error SyncPriority
        priority flags
            | o && t    = Left ErrSyncBothOursTheirs
            | o         = Right SyncOurs
            | t         = Right SyncTheirs
            | otherwise = Right SyncDefault
            where
                o = OptionOurs `elem` flags
                t = OptionTheirs `elem` flags

-- | Execute the 'sync' command.
--
doSync :: Bool -> SyncPriority -> [String] -> EnvIO ExitStatus
doSync dry priority params = do
    result <- callWebService "directory" MsgNull ProgressNone
    case result >>= parseFileList of
        Left err -> do
            liftIO $ putErr err
            return StatusInvalidServerResponse
        Right remote' -> do
            (_, _, Just root) <- ask
            (errlist, local'', filemap) <- liftIO $ buildFileList root
            forM_ errlist (\(upath, err) ->
                printAction AnsiRed "error" (Just (show err)) (makeRelative root (rebuildFilePath filemap upath)))

            cwd <- liftIO $ getWorkingDirectory
            if not (root `isPrefixOf` cwd) then error "internal consistency" else return ()
            let synconly = rights $ map (parsePattern . (++) "./" . makeRelative root . combine cwd) params

            patterns <- map snd <$> getPatternList
            let remote = filterRemoteList not patterns $ filterRemoteList id synconly $ remote'
            let local' = filterLocalList not patterns $ filterLocalList id synconly $ local''
            local <- liftIO $ mapM (getFileHash filemap) (sortBy compareFiles local')
            cache <- sortBy compareFiles <$> filterRemoteList id synconly <$> getFileList

            let actions = computeActions priority (computeChanges cache local) (computeChanges cache remote)
            let (before, actions') = partition doesCreateDir actions
            let (after, middle) = partition doesDeleteDir actions'

            oks <- forM (before ++ middle ++ reverse after) (\(upath, action) -> do
                let path = rebuildFilePath filemap upath
                let (desc, extra, color, justdoit) = getActionInfo upath path action
                printAction color desc extra (makeRelative root path)
                if dry then return True else do
                    ret <- justdoit
                    case ret of
                        Left err -> liftIO (putErr err) >> return False
                        Right _  -> return True)

            return $ if (and oks) then StatusOK else StatusSynchronizationFailed

    where
        parseFileList :: MsgValue -> Either Error [(UFilePath, B.ByteString)]
        parseFileList msg = case msg !? "result" >>= parselist of
            Just r  -> Right $ sortBy compareFiles r
            _       -> Left (ErrCloudGeneric "invalid server response")
            where
                parselist :: MsgValue -> Maybe [(UFilePath, B.ByteString)]
                parselist (MsgArray a)  = sequence $ map parsefile a
                parselist _             = Nothing

                parsefile :: MsgValue -> Maybe (UFilePath, B.ByteString)
                parsefile file = case (file !? "f", file !? "h") of
                        (Just (MsgString f), Just (MsgString h)) -> Just (f, encodeUtf8 h)
                        _                                        -> Nothing

        compareFiles :: (UFilePath, a) -> (UFilePath, a) -> Ordering
        compareFiles (f1, _) (f2, _) = compare f1 f2

        printAction :: AnsiColor -> String -> Maybe String -> FilePath -> EnvIO ()
        printAction color desc extra path = liftIO $ putStrLn $ foreColor color text
            where
                eol = case extra of
                    Just t  -> " (" ++ t ++ ")"
                    Nothing -> ""
                filling = replicate (15 - length desc) ' '
                text = "    " ++ desc ++ ":" ++ filling ++ path ++ eol

-----------------------------------------------------------------------------

-- | Print usage for the remote command.
--
helpSync :: IO ()
helpSync = do
    putLine $ "{*:USAGE}}"
    putLine $ "    {y:nubo sync}} [{y:-d}} | {y:--dry}}] [{y:-t}} | {y:--theirs}} | {y:-o}} | {y:--ours}}] [{y:files...}}]"
    putLine $ ""
    putLine $ "{*:DESCRIPTION}}"
    putLine $ "    Synchronise the local computer with the remote cloud. Locally modified files"
    putLine $ "    are uploaded to the server while remotely modified files are downloaded."
    putLine $ "    This command may be run from any subfolder below the {y:nubo}} root folder,"
    putLine $ "    including symlink'd directories."
    putLine $ ""
    putLine $ "    You can optionally restrict synchronisation to specific files or folders, by"
    putLine $ "    specifying which elements to synchronise on the command line. Wildcards are"
    putLine $ "    not supported, but this should not be a limitation on Unix-like systems"
    putLine $ "    where shell parameter expansion applies."
    putLine $ ""
    putLine $ "    When a file was both locally and remotely modified, a conflict appears. In"
    putLine $ "    that case, {y:nubo}} simply prints an informative message and does not touch the"
    putLine $ "    file. You can then run another synchronisation with the {y:--theirs}} or {y:--ours}}"
    putLine $ "    flags to tell {y:nubo}} which version to keep. For example:"
    putLine $ ""
    putLine $ "        {y:nubo sync --theirs foo.txt}}  keep remote version of foo.txt"
    putLine $ "        {y:nubo sync --ours bar.txt}}    keep local version of bar.txt"
    putLine $ "        {y:nubo sync --theirs}}          keep remote versions of all files in"
    putLine $ "                                    conflict"
    putLine $ ""
    putLine $ "    Note that these flags only apply to conflicting elements. They do not affect"
    putLine $ "    synchronisation of other files in any way."
    putLine $ ""
    putLine $ "    The {y:--dry}} option simulates a synchronisation. It prints a list of actions"
    putLine $ "    to undertake to synchronise local and remote folders, but does not actually"
    putLine $ "    perform these actions. It is a good practice to run a dry synchronisation"
    putLine $ "    before a real one, especially when debuting with {y:nubo}}, to ensure that it"
    putLine $ "    behaves as expected and that you won't lose your data."
    putLine $ ""
    putLine $ "    Files and folders that match any of the pattern set by the {y:nubo ignore}}"
    putLine $ "    command are purely ignored."
    putLine $ ""
    putLine $ "{*:OPTIONS}}"
    putLine $ "    {y:-d}}, {y:--dry}}       Simulate a synchronisation."
    putLine $ "    {y:-t}}, {y:--theirs}}    Resolve conflicts by keeping remote version of files."
    putLine $ "    {y:-o}}, {y:--ours}}      Resolve conflicts by keeping local version of files."
    putLine $ ""

-----------------------------------------------------------------------------