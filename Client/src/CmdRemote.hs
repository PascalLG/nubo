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

module CmdRemote (
      cmdRemote
    , helpRemote
) where

import Control.Monad.Trans (liftIO)
import PrettyPrint
import Misc
import Error
import Database

-----------------------------------------------------------------------------

-- | Parse arguments for the 'remote' command.
--
cmdRemote :: [String] -> IO ExitStatus
cmdRemote args = case parseArgs args [] of
    Left err         -> putErr err >> return StatusInvalidCommand
    Right (_, (a:_)) -> putErr (ErrExtraArgument a) >> return StatusInvalidCommand
    Right (_, [])    -> openDBAndRun newEnv doRemote

-- | Execute the 'remote' command.
--
doRemote :: EnvIO ExitStatus
doRemote = getConfig CfgRemoteURL >>= \(Just url) -> do
    liftIO $ putStrLn url
    return StatusOK

-----------------------------------------------------------------------------

-- | Print usage for the remote command.
--
helpRemote :: IO ()
helpRemote = do
    putLine $ "{*:USAGE}}"
    putLine $ "    {y:nubo remote}}"
    putLine $ ""
    putLine $ "{*:DESCRIPTION}}"
    putLine $ "    Print the URL of the cloud the current folder synchronises with. An error"
    putLine $ "    occurs if neither the current folder nor one of its parent is associated"
    putLine $ "    with a {y:nubo}} cloud."
    putLine $ ""
    putLine $ "{*:OPTIONS}}"
    putLine $ "    None."
    putLine $ ""

-----------------------------------------------------------------------------