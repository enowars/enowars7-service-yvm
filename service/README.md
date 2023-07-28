# yvm

The `yvm`, a toy JVM written in OCaml with some web code and a minimal notes
app that runs on it.
It supports:

- `int` and `char` primitive types, and (multidimensional) arrays thereof
- static methods and fields
- rudimentary classloading, i.e.\ users can reference static methods and fields
  of available classes
- native `print` methods to print the supported types, i.e. `print(int i)`,
  `print(char c)` etc.
- Some more native methods to allow the `Notes` class to do I/O.

It does neither support `long`, `float` and `double`, nor instantiating objects
via `new`, nor invoking non-static methods, nor inheritance, interfaces, etc.

## Development environment

1. [Install nix](https://github.com/DeterminateSystems/nix-installer) and the
   e.g. the [OCaml
   Platform](https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform)
   VS Code Extension.
1. run `nix develop` to obtain a shell with all required dependencies and start
   VS Code in that shell.
1. Use dune to test and run the `yvm`:
    - `dune runtest`
    - `javac Foo.java; dune exec yvm Foo.class`

For an end-to-end test, also run the checker and test with
[enochecker_test](https://github.com/enowars/enochecker_test).

The service can be (re)started with `docker compose up --build -d`.
