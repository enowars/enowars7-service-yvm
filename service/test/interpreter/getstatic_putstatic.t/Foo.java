class Foo {
	static native void print(int x);

	static int x = 123;

	public static void main(String[] args) {
		x = x + Bar.x;
		print(x);
	}
}
