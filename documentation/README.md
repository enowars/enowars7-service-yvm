- how the service works in general
- the vulns
- the exploits
- the fixes

> all one needs to know to use the service at some later point (e.g. BambiCTF)
> or for people to understand your service post-CTF.

# YVM

## Service Features

This service offers two distinct features:
The user can either upload and run Java bytecode or can store and retrieve
notes via the YNotes app.

## YVM Architecture

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
class file or the `Notes` class that implements the _YNotes_ app.

### YVM features

The `yvm` supports:

- `int` and `char` primitive types, and (multidimensional) arrays thereof
- static methods and fields
- rudimentary classloading, i.e.\ users can reference static methods and fields
  of previously uploaded classes
- native `print` methods to print the supported types, i.e. `print(int i)`,
  `print(char c)` etc.
- native `dump` method to print the interpreter state.
- Some more native methods to allow the `Notes` class to do I/O.

It does neither support `long`, `float` and `double`, nor instantiating objects
via `new`[^1], nor invoking non-static methods.

[^1]: Note that arrays differ in this case from Objects, as they are
  created by the supported `newarray` and `anewarray` instructions as opposed
  to the unsupported `new` instruction.

### Run Code

1. The user uploads a Java [class
   file](https://docs.oracle.com/javase/specs/jvms/se20/html/jvms-4.html) as
   obtained by compiling Java code with `javac` via the web form.
1. The PHP script saves the file into the `classes/` folder and invokes the
   `yvm` to run it.
1. The `yvm` interprets the code. If it encounters a reference to another class
   `$CLASS`, it tries to load the classfile `classes/$class.class`.
1. The PHP script collects the yvm's exit code, `stdout` and `stderr` and
   displays this output back to the user.
   It also generates a `replay_id` to allow the re-execution of the uploaded
   class file.

### YNotes

Note that the user interacts with the HTML/PHP which invokes `yvm` which
interprets the `Notes.class`, that is stored in `classes/`.

1. The user opens the YNotes Subpage.
1. If the `token` cookie is not already set, the `Notes` class with argument
   `r` (for "register") is run by `yvm`.
    1. `Notes` creates a new directory with a random name prefixed with the
        current time in `notes/`.
    1. The name of the newly created directory is set as a cookie with the key
       `token` to identify the user.
1. The `token` cookie is read and `Notes` with arguments `l` (for "list) and
   `$token` (value of the token).
    1. `Notes` prints the content of the directory `$token`.
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

The checker encodes the flag as integers, stores them as `static` members in a class
with a random name and uploads that class.

### `notes/`

The checker saves the flag as the content of a note with name `flag` and
retrieves the flag via the `token` cookie.
