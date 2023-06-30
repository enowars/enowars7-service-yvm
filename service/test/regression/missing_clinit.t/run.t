  $ javac -d . Foo.java

Ensure that yvm does not try to run Bar.<clinit>
  $ yvm Foo.class
