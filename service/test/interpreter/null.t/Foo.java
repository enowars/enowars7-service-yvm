class Foo {

	static char[] x;

	native static void print(char[] x);

	public static void main(String[] args) {
		if (x == null) {
			print(x);
		}
	}
}
