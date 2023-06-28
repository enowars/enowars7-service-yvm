# TODO

- pipeline for `fixed`
- make service usage more _understandable_ by improving `index.html`:
    - add unit test that covers "usual usage" case, generate docs from it

## Plan

1. refactor to more functional style
1. Support more types
1. add low-effort instructions: `imul`, `iconst_<n>`, etc.
1. Static methods / `invokestatic`
1. `printInt`, `printChar`
1. `readChar`

I'm unsure how difficult implementing Arrays (use case: Strings) would be.
But they aren't required for the current plan (e.g. char by char disk I/O)
