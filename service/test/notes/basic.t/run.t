  $ cp ../../../Notes.java .

  $ javac -d . Notes.java

  $ yvm Notes.class r > token

  $ yvm Notes.class a $(cat token) note_1 foo

  $ yvm Notes.class a $(cat token) note_2 bar

  $ yvm Notes.class l $(cat token) | sort
  note_1
  note_2

  $ yvm Notes.class g $(cat token) note_1
  foo

We grep for error to suppress the non-deterministic error msg
  $ yvm Notes.class g $(cat token) note_none 2>&1 | grep "^error"
  error: read
