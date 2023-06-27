class Foo {
	static int x = 123;

	public static void main(String[] args) {
		x = Bar.x + Bar.x;
	}
}
