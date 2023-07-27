  $ cp ../../../Notes.java .
  $ javac -d . Notes.java

  $ yvm Notes.class r | tr -d '\n' > token

  $ yvm Notes.class a $(cat token) note mysecret

  $ echo "" > token

  $ yvm Notes.class l . | grep "^[0-9]\{4\}" > stolen_token
  error: arg
  [1]
