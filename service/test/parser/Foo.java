class Foo {
    private static volatile int a = 0;
    final static double b = 12.3;
    static long c = 1337;
    float d = 12.3f;
    String l = "getMyLong";
    static Object f;

    private static int getMyInt() {
            int my = 123 + 456;
            return my;
    }

    private long getMyLong() {
            long my = 123l + 456l;
            return my;
    }

    public static void main(String[] args) {
        int x = 3 ;
        int y = getMyInt();
        System.out.println(x + ", " + y);
	Foo f = new Foo();
	c = f.getMyLong();
    }
}
