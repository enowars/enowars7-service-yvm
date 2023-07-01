class Foo {
	static char[] x = { 's', 'u', 'c', 'c' };

	static native void print(char[] x);

	public static void main(String[] args) {
		print(x);
	}
}
