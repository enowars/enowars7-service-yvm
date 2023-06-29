class Foo {
	static int foo(int x, int y) {
		return x + x + y;
	}

	static int x;

	public static void main(String[] args) {
		x = foo(1000000, 1);
	}
}
