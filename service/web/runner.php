<?php

require "util.php";

function run_file($filename) {
  $filename = trim($filename);

  [$return_value, $stdout, $stderr] = run_yvm($filename, "classes");

  echo "<p>Ran $filename with vm exit code <code>$return_value</code>.</p>";

  echo "<figure>";
  echo "<figcaption>stdout</figcaption>";
  echo "<pre>";
  echo "<code spellcheck='false'>";
  echo $stdout;
  echo "</code>";
  echo "</pre>";
  echo "</figure>";

  echo "<figure>";
  echo "<figcaption>stderr</figcaption>";
  echo "<pre>";
  echo "<code spellcheck='false'>";
  echo $stderr;
  echo "</code>";
  echo "</pre>";
  echo "</figure>";
}

const REPLAY_FILE = "classes/replay.tsv";
const REPLAY_KEY = "replay_id";

if (isset($_GET[REPLAY_KEY])) {
  if (file_exists(REPLAY_FILE)) {
    foreach (file(REPLAY_FILE) as $_ => $line) {
      $e = explode(" ", $line);
      if ($e[0] == $_GET[REPLAY_KEY]) {
        run_file($e[1]);
        exit;
      }
    }
  }
  die_with(404, "<p>Sorry, unknown replay_id.</p>");
}

if (!isset($_FILES["fileToUpload"])) {
  die_with(400, "<p>Sorry, expecting file upload.</p>");
}

$target_dir = "classes/";
$filename = basename($_FILES["fileToUpload"]["name"]);
$target_file = $target_dir . $filename;

$regex = "/[A-Za-z]+\.class/";
if (!preg_match($regex, $filename)) {
  die_with(400, "<p>Sorry, expecting filename that matches $regex.</p>");
}

// Check if file already exists
if (file_exists($target_file)) {
  die_with(400, "<p>Sorry, file already exists.</p>");
}

if (!move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
  error_log("<p>Sorry, there was an error uploading your file.</p>");
  die_with(500, "<p>Sorry, there was an error uploading your file.</p>");
}

$id = bin2hex(random_bytes(16));
if(!file_put_contents(REPLAY_FILE, "$id $filename " . time() . "\n", FILE_APPEND | LOCK_EX)) {
  error_log("error writing replay file!");
  die_with(500,"error writing replay file!");
}

echo "<p>The file " . $filename . " has been uploaded.</p>";

echo "<p>You can replay the file via the replay_id <a href='runner.php?" . REPLAY_KEY . "=$id'>$id</a>.</p>";

run_file($filename);
?>
