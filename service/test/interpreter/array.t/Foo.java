class Foo {
	native static void print(char x);

	public static void main(String[] args) {
		char[] x = new char[10];
		x[5] = 'c';
		print(x[5]);
	}
}
