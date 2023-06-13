# TODO

- [ ] fixing patch
- [ ] cleanup of old flags

## Implementation State

The `yvm`  currently supports the following instructions of the ~170
instructions in the [JVM Instruction
Set](https://docs.oracle.com/javase/specs/jvms/se20/html/jvms-6.html#jvms-6.5).

```
iconst_1
iconst_5
bipush
sipush
ldc
aload
aload_0
istore_1
iadd
return
getstatic
putstatic
```

I intend to implement two refactorings of the main interpreter loop before
adding more instructions, so I have less code to refactor.

## Plan

1. check if refactoring the [main interpreter
   loop](https://github.com/enowars/enowars7-service-yvm/blob/79057e335b8a40cfcba80cde5245f4e96d2f7210/service/src/jinterpreter.ml#L29)
   into a tail-call style feels good.
1. Support all (or at least most) types, not just integers.
1. add low-effort instructions (e.g. `imul`, the missing `iconst_<n>`, etc.).
1. Method calling/stack.
1. `printInt`, `printChar`
    - change service output from _internal state dump_ to _interpreter stdout_.
      This could add a cool mitigation: simply disallow printing of flags.
      (which could be avoided by "encrypting" flag, printing, "decrypting",
      submitting.
1. disk I/O
    - potential 2nd flag store: files created by other yvm invocations. Maybe
      implement in such a way that a simple permission system would have to be
      added.

I'm unsure how difficult implementing Arrays (use case: Strings) would be.
But they aren't required for the current plan (e.g. char by char disk I/O)
