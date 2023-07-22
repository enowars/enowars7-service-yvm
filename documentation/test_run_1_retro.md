---
aspectratio: 169
---

# yvm

## The Service

### Yvm

1. PHP scaffold saves classfile, calls `yvm` as subprocess
1. `yvm` reads classfile
1. runs `main`
    - might load more classfiles
1. dumps internal state

. . .

since it was called _advanced_ ...

. . .

It's IMHO:

- __easy__ / __medium__ to exploit
- __medium__ ~ __hard__ to fix


### Vuln: Intended Journey

1. Attack info: `'{"no_ints": 13, "class_name": "VICARIPICU"}'`
1. See `VICARIPICU.class` in folder
1. `javap` / disassemble, see:
   ```java
   private static int secret_length = 13;
   private static int secret_1      = 1162760001;
   private static int secret_2      = 1094795585;
   ```
1. figure out flag encoding
   ```python
   b = "ENOA".encode()
   int.from_bytes(b, byteorder="big", signed=True)  # 1162759985
   ```
1. figure out access vector
   ```java
   static int get_len = VICARIPICU.secret_length;
   static int get_1   = VICARIPICU.secret_1;
   ```

### Mitigation

```diff
@@ -7,6 +7,8 @@ get_field (t : t) (caller : string) (klass : string)
   match List.assoc_opt klass !t with
   | Some kpool -> (
       match List.assoc_opt nat kpool.fields with
       | Some (_, entry) -> entry
       | None -> failwith "invalid nat into loaded class")
```

### Mitigation

```diff
@@ -7,6 +7,8 @@ get_field (t : t) (caller : string) (klass : string)
   match List.assoc_opt klass !t with
   | Some kpool -> (
       match List.assoc_opt nat kpool.fields with
+      | Some (Some Jparser.ACC_PRIVATE, entry) ->
+          if caller = klass then entry else failwith "invalid access"
       | Some (_, entry) -> entry
       | None -> failwith "invalid nat into loaded class")
```

## The Test Run

### What I did

Checker _CPU-heavy_ due to `javac`

- fix: precompiled classes and `bytes.replace()`

Service _flaky_ due to two bugs

- `uniqid`
- `stdout`/`stderr` output file race

Took most of the time to debug

- missing checker logging
- acquainting myself with elk
- enochecker3 #36 (assert logging), #37 (request logging)

### Feedback

Service was played and exploited by people that already knew it.

- clarify "usual usage"
- unsure how difficult fixing would be

No attempts to patch the service yet.

- Would be interesting for feedback.

## The Future

### Plan

#### TODO

- checker: to not use `javac`
- make service usage more _understandable_

#### Roadmap

1. refactor to more functional style
1. Support more types
1. add low-effort instructions: `imul`, `iconst_<n>`, etc.
1. Static methods / `invokestatic`
1. `printInt`, `printChar`
1. `readChar`
