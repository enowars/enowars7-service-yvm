class Foo {
	static int foo(int x, int y) {
		return x + x + y;
	}

	static native void print(int x);

	public static void main(String[] args) {
		print(foo(1000000, 1));
	}
}
