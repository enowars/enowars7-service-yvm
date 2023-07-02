<h1>YNotes</h1>
<?php
function run_notes(...$args) {

  $fd_spec = array(
     1 => array("pipe", "w"),
     2 => array("pipe", "w"),
  );

  array_unshift($args, "../yvm", "Notes.class");

  $process = proc_open($args, $fd_spec, $pipes, getcwd() . "/notes");

  if (!is_resource($process)) {
    die ("could not open process");
  }

  $stdout = stream_get_contents($pipes[1]);
  $stderr = stream_get_contents($pipes[2]);

  fclose($pipes[1]);
  fclose($pipes[2]);

  assert(proc_close($process) == 0);

  return trim($stdout);
}

if (!isset($_COOKIE["token"])) {
  $token = run_notes("r");
  setcookie("token", $token, time() + 60 * 60 * 24 * 30);
} else {
  $token = $_COOKIE["token"];
}

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

$notes = explode("\n", run_notes("l", $_COOKIE["token"]));

if (count($notes) == 0) {
  echo "<p>You don't have any notes yet.</p>";
} else {
  echo "<h2>Your Notes</h2>";
  echo "<ul>";
  foreach ($notes as $note) {
    echo "<li><a href='notes.php?show=$note'>$note</a>";
  }
  echo "</ul>";
}

?>

<form action="notes.php" method="post">
  <h2>Add Note</h2>
  <ul>
    <li>
      <label for="name">Name of Note</label>
      <input type="text" id="name" name="name" />
    </li>
    <li>
      <label for="content">content</label>
      <textarea id="content" name="content"></textarea>
    </li>
    <li class="button">
      <button type="submit">Send your message</button>
    </li>
  </ul>
</form>
