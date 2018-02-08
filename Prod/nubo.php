<?php
    //-----------------------------------------------------------------------------
    // Nubo Server Installer
    // Copyright (c) 2017, Pascal Levy
    //
    // Permission is hereby granted, free of charge, to any person obtaining a copy
    // of this software and associated documentation files (the "Software"), to deal
    // in the Software without restriction, including without limitation the rights
    // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    // copies of the Software, and to permit persons to whom the Software is
    // furnished to do so, subject to the following conditions:
    //
    // The above copyright notice and this permission notice shall be included in
    // all copies or substantial portions of the Software.
    //
    // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    // THE SOFTWARE.
    //-----------------------------------------------------------------------------

    $content = <<<EOT
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
EOT;

    define('MIN_PHP_VERSION', 7);
    define('MIN_INT_SIZE', 4);
    define('REQUIRED_EXTENSIONS', 'sqlite3 zip');
    define('TMP_FILE', 'tmp.zip');

    function checkCompatibility() {
        $retval = '';
        $version = explode('.', phpversion());
        if (!isset($version[0]) || intval($version[0]) < MIN_PHP_VERSION) {
            $retval .= "<li>PHP " . MIN_PHP_VERSION . " or higher is required</li>";
        }
        if (PHP_INT_SIZE < MIN_INT_SIZE) {
            $retval .= "<li>A 64-bit version of PHP is required</li>";
        }
        if (!is_writable('.')) {
            $retval .= "<li>Cannot write in the current folder</li>";
        }
        foreach (explode(' ', REQUIRED_EXTENSIONS) as $ext) {
            if (!extension_loaded($ext)) {
                $retval .= "<li>Missing PHP $ext extension</li>";
            }
        }
        return $retval;
    }

    function unzipFiles() {
        global $content;
        $retval = false;
        if (file_put_contents(TMP_FILE, base64_decode($content)) > 0) {
            $zip = new ZipArchive;
            if ($zip->open(TMP_FILE) === true) {
                if ($zip->extractTo('.')) {
                    $retval = true;
                }
                $zip->close();
            }
            @unlink(TMP_FILE);
        }
        return $retval;
    }
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr" lang="fr">
<head>
	<title>Nubo Installer</title>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
</head>
<body>
<?php 
    if (($errors = checkCompatibility()) != '') {
        echo "<p>Installation failed because of the following issues:</p>";
        echo "<ul>$errors</ul>";
    } elseif (!unzipFiles()) {
        echo "<p>Unexpected error while unzipping archive.</p>";
    } else {
        echo "<p>Installation successful. Click <a href=\"index.php\">here</a> to configure and start your nubo server.</p>";
        if (strpos(__FILE__, 'install.php') !== false) {
            @unlink(__FILE__);
        }
    }
?>
</body>
</html>
