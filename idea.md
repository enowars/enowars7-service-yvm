
"flagship" app: notes

- security: registration (gen token) + basic auth

- notes
	- directory per token
	- files in dir: key: name, val: content
	- `listNotes(token)`
	- `getNote(token, name)`
	- vuln: path traversal

- impl
	- input per args, output stdout
	- int-basiert

https://docs.oracle.com/javase/specs/jvms/se20/html/jvms-6.html#jvms-6.5.newarray
