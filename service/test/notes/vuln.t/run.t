  $ cp ../../../Notes.java .
  $ javac -d . Notes.java

  $ yvm Notes.class r > token

  $ yvm Notes.class a $(cat token) note "my secret"

  $ echo "" > token

  $ yvm Notes.class l . | grep "^[0-9]\{4\}" > stolen_token

  $ yvm Notes.class g $(cat stolen_token) note
  my secret
