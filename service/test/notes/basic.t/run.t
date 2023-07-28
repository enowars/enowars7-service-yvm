  $ cp ../../../Notes.java .

  $ javac -d . Notes.java

  $ yvm Notes.class r | tr -d '\n' > token

  $ yvm Notes.class a $(cat token) note1 foo

  $ yvm Notes.class a $(cat token) note2 bar

  $ yvm Notes.class l $(cat token) | sort
  note1
  note2

  $ yvm Notes.class g $(cat token) note1
  foo

We grep for error to suppress the non-deterministic error msg
  $ yvm Notes.class g $(cat token) notenone 2>&1 | grep "^error"
  error: read
