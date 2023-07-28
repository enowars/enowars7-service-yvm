# YVM

This service offers two distinct features:
The user can either upload and run Java bytecode or can store and retrieve
notes via the YNotes app.

## Architecture

The core of the service is the _yvm_, a
toy-[JVM](https://en.wikipedia.org/wiki/Java_virtual_machine).

The user interacts with the HTML/PHP part of the service.
The PHP code then invokes the `yvm`, which interprets Java bytecode.

```
        USER
          ^
          v
      +-------+
      |  PHP  |
      +-------+
        |   ^
  forks |   | exit code,
        v   | stdout, stderr
      +-------+
      |  yvm  |
      +-------+
  inter-|   ^
  prets |   | native
        v   | methods
    +------------+
    | class file |
    +------------+
```

Depending on the used feature, the `yvm` either interprets the user-supplied
class file or the `Notes` class[^Notes] that implements the _YNotes_ app.

[^Notes]: c.f. `/service/Notes.java`

### YVM Capabilities

The `yvm` supports:

- `int` and `char` primitive types and (multidimensional) arrays thereof.
- static methods and fields.
- rudimentary classloading, i.e. users can reference static methods and fields
  of previously uploaded classes.
- native `print` methods to print the supported types, i.e. `print(int i)`,
  `print(char c)` etc.
- Some more native methods to allow the `Notes` class to do I/O.

It does neither support `long`, `float` and `double`, nor instantiating objects
via `new`[^new], nor invoking non-static methods, nor inheritance, interfaces,
etc.

[^new]: Note that arrays differ in this case from Objects, as they are
  created by the supported `newarray` and `anewarray` instructions as opposed
  to the unsupported `new` instruction.

### Execution Flow per Feature

#### Run Code

1. The user uploads a Java [class
   file](https://docs.oracle.com/javase/specs/jvms/se20/html/jvms-4.html)[^compile]
   via the web form.
1. The PHP script saves the file into the `classes/` folder and invokes the
   `yvm` to run it.
1. The `yvm` interprets the code. If it encounters a reference to another class
   `$CLASS`, it tries to load the classfile `classes/$CLASS.class`.
1. The PHP script collects the yvm's exit code, `stdout` and `stderr` and
   displays this output back to the user.
   It also generates a `replay_id` to allow the re-execution of the uploaded
   class file.

[^compile]: As obtained by compiling Java code with `javac`

#### YNotes

Note that the user interacts with the HTML/PHP code which invokes `yvm` which
interprets the `Notes.class`, that is stored in `classes/`.

1. The user opens the YNotes Subpage.
1. If the `token` cookie is not already set, the `Notes` class with argument
   `r` (for "register") is run by `yvm`.
    1. `Notes` creates a new directory with a random name prefixed with the
        current time in `notes/`.
    1. The name of the newly created directory is set as a cookie with the key
       `token` to identify the user.
1. The `token` cookie is read and `Notes` is run with arguments `l` (for
   "list") and `$token` (value of the token).
    1. `Notes` lists the content of the directory `$token`.
    1. The output is displayed back to the user as a list of notes.
1. If the user creates a note via the web form, `Notes` is run with arguments
   `a` (for "add"), `$token`, `$name` (of note) and `$content` (of note).
    1. If it does not already exist, `Notes` creates a file `$token/$name`
       (executed in the `notes/` directory) with content `$content`.
1. If the user requests to see the content of note `$note`, `Notes` is run with
   arguments `g` (for "get"), `$token` and `$note`.
    1. `Notes` tries to read the file `$token/$note` (executed in the `notes/`
       directory).
    1. The result is displayed to the user.

## Flag Stores

### `classes/`

The checker encodes the flag as integers, stores them as `private static` members in a class
with a random name and uploads that class.
The integers are printed during execution of the class.
The flag is retrieved by re-executing the class via the `replay_id`.

The flag encoding scheme is the following:

```
"ENO🚩"   <=>   E    N    O    <4-byte flag emoji>
                |    |    |            |
                |    |    |    +-----+-+--+----+
                v    v    v    v     v    v    v
               0x45 0x4e 0x4f 0xf0  0x9f 0x9a 0xa9 [0x00 padding]
               \                 /  \                /
                \               /    \             /
                    0x454e4ff0         0x9f9aa900
                        ^                 ^
                        |                 |
                        v                 v
                    1162760176        -1617254144

                                  ^
                                  |
                                  v

              private static secret_length = 7;
              private static secret_0 =  1162760176;
              private static secret_1 = -1617254144;
```

### `notes/`

The checker saves the flag as the content of a note with name `flag` and
retrieves the flag via the `token` cookie.

## Vulnerabilities

The service has three vulnerabilities.
The first two allow access to both flag stores, the last only compromises the
`classes/` flag store.

Each vuln is fixed by a commit on the `fixed` branch.

### Path Traversal via `token` cookie

As described earlier, YNotes sets a cookie that is interpreted by the
application as a file system path.

An attacker can set this cookie to e.g. `.` or `/var/www/html/notes` to get a
directory listing of all notes folders.
Since the folder name/`token` authenticates the user, obtaining a directory
listing of `notes/` compromises all users.
The attacker can then iterate through the newest directories (identifiable by
the creation time prefix) to find the current flag.

The vuln is fixed by only allowing `[a-z0-9]` as the second (`token`) and third
(name of note) parameter handed to `Notes`.

### Non-private `ls`, `read` Method in `Notes.java`

`Notes.java` has multiple native helper methods (`ls`, `mkdir`, `read`,
`write`, etc.).
The `yvm` ensures, that these native methods can only be called by the `Notes`
class and `mkdir` and `write` are already declared private to prevent DOS by
file/dir creation.

But the `ls` and `read` methods are _not_ declared private. So while a class `Foo`
cannot use a `ls` method declared by itself due to the `yvm` check, it can call
`Notes.ls(...)` since the method is not (yet) private.

The vuln is fixed by changing the visibility of the native methods in
`Notes.java` to private.

### Access to private class fields

While the `yvm` prevents the illegal access of private methods, the
corresponding check for private fields is missing.
Thus, an attacker can create a class `Foo` that prints the private `secret_...`
fields of the class containing the flag, whose name is known from the attack
info.

Note that the `yvm` crashes when calling the `main(String[] args)` method of
another class, so this attack vector can be ruled out.

The vuln is fixed by raising an error when a private field is accessed from a
different class.
