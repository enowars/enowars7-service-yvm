class Foo {
	native static void print(char[][][] x);

	public static void main(String[] args) {
		char[][][] x = new char[1][][];

		char[][] x0 = new char[2][];
		x[0] = x0;

		char[] x00 = {'n', 'a'};
		char[] x01 = {'i', 's'};
		x0[0] = x00;
		x0[1] = x01;

		print(x);
	}
}
