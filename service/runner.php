<?php

$target_dir = "classes/";
$filename = basename($_FILES["fileToUpload"]["name"]);
$target_file = $target_dir . $filename;
$uploadOk = 1;

// Check if file already exists
if (file_exists($target_file)) {
  echo "<p>Sorry, file already exists.</p>";
  $uploadOk = 0;
}

if ($uploadOk == 0) {
  echo "<p>Sorry, your file was not uploaded.</p>";
} else {
  if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
    echo "<p>The file ". htmlspecialchars($filename). " has been uploaded.</p>";

    echo shell_exec("cd classes; ../yvm " . $filename);
  } else {
    echo "<p>Sorry, there was an error uploading your file.</p>";
  }
}
?>
<br>
<a href=".">go back.</a>
