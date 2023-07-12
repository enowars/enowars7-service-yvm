<?php

require "util.php";

function run_notes(...$args) {
  [$exit_code, $stdout, $stderr] = run_yvm("../classes/Notes.class", "notes", ...$args);
  if ($exit_code != 0) {
    echo "<p>An Error occured: yvm exit code <code>$exit_code</code></p>\n";
    echo "<pre><code>\n";
    echo $stderr;
    echo "</code></pre>\n";
  }
  return trim($stdout);
}

if (!isset($_COOKIE["token"])) {
  $token = run_notes("r");
  setcookie("token", $token, time() + 60 * 60 * 24 * 30);
} else {
  $token = $_COOKIE["token"];
}

echo "<h1>YNotes</h1>";

if (isset($_POST["name"])) {
  run_notes("a", $token, $_POST["name"], $_POST["content"]);
}

if (isset($_GET["show"])) {
  $note = $_GET["show"];
  echo "<h2>Your Note $note</h2>";
  echo "<pre>";
  echo run_notes("g", $token, $note);
  echo "</pre>";
}

$notes = run_notes("l", $token);

if ($notes === "") {
  echo "<p>You don't have any notes yet.</p>";
} else {
  echo "<h2>Your Notes</h2>";
  echo "<ul>";
  foreach (explode("\n", $notes) as $note) {
    echo "<li><a href='notes.php?show=$note'>$note</a>";
  }
  echo "</ul>";
}

?>

<form action="notes.php" method="post">
  <h2>Add Note</h2>
  <ul>
    <li>
      <label for="name">Name</label>
      <br>
      <input type="text" id="name" name="name" />
    </li>
    <li>
      <label for="content">Content</label>
      <br>
      <textarea id="content" name="content"></textarea>
    </li>
    <li class="button">
      <button type="submit">Add Note</button>
    </li>
  </ul>
</form>
