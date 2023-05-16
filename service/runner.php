<?php

function run_file($filename) {
  echo "<p>yvm output:</p>";

  echo "<pre>";
  echo shell_exec("cd classes; ../yvm $filename");
  echo "</pre>";
}

const REPLAY_FILE = "classes/replay.tsv";
const REPLAY_KEY = "replay_id";

if (isset($_GET[REPLAY_KEY])) {
  if (file_exists(REPLAY_FILE)) {
    foreach (file(REPLAY_FILE) as $_ => $line) {
      $e = explode(" ", $line);
      if ($e[0] == $_GET[REPLAY_KEY]) {
        run_file($e[1]);
        die;
      }
    }
  }
  echo "<p>Sorry, unknown replay_id.</p>";
  die;
}

if (!isset($_FILES["fileToUpload"])) {
  echo "<p>Sorry, expecting file upload.</p>";
  die;
}

$target_dir = "classes/";
$filename = basename($_FILES["fileToUpload"]["name"]);
$target_file = $target_dir . $filename;

$regex = "/[A-Za-z]+\.class/";
if (!preg_match($regex, $filename)) {
  echo "<p>Sorry, expecting filename that matches $regex.</p>";
  die;
}

// Check if file already exists
if (file_exists($target_file)) {
  echo "<p>Sorry, file already exists.</p>";
  die;
}

if (!move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
  echo "<p>Sorry, there was an error uploading your file.</p>";
}

echo "<p>The file " . $filename . " has been uploaded.</p>";

$id = uniqid();
echo "<p>You can replay the file via the replay_id <a href='runner.php?" . REPLAY_KEY . "=$id'>$id</a>.</p>";

file_put_contents(REPLAY_FILE, "$id $filename\n", FILE_APPEND | LOCK_EX);

run_file($filename);
?>
