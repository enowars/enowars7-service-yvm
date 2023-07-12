<?php
function run_yvm($class, $dir, ...$args) {
  $fd_spec = array(
     1 => array("pipe", "w"),
     2 => array("pipe", "w"),
  );

  array_unshift($args, "../yvm", $class);

  $process = proc_open($args, $fd_spec, $pipes, getcwd() . "/$dir",
                       array("OCAMLRUNPARAM" => "b"));

  if (!is_resource($process)) {
    die ("could not open process");
  }

  $stdout = stream_get_contents($pipes[1]);
  $stderr = stream_get_contents($pipes[2]);

  fclose($pipes[1]);
  fclose($pipes[2]);

  $exit_code = proc_close($process);

  error_log("run_yvm: [" . implode(", ", $args) . "] in ./$dir.\nexit_code: $exit_code,\nstdout:\n$stdout\nstderr:\n$stderr\n");

  return [$exit_code, $stdout, $stderr];
}
?>
