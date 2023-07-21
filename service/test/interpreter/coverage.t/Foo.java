class Foo {
	native static char[][] getArgs();
	native static void print(char x);
	native static void print(int x);
	native static void print(int[] x);
	native static void print(char[] x);

	public static void main(String[] _args) {
		char[][] args = getArgs();

		char[] a1 = new char[10];
		char[] a2 = null;

		if (a1 == a2) {
			print('0');
		}
		if (a2 == a1) {
			print('1');
		}
		if (a1 != a1) {
			print('2');
		}

		int x = args[0][0];
		int y = args[1][0];

		int[] is = new int[3];
		for (int i = 0; i < is.length; i++) {
			is[i] = i * i;
		}

		if (x - 2       !=  y - 1 - y/y) print('3');
		if (x * 2       != y + y)        print('4');
		if ((x + x) / 2 !=  y)           print('5');
		if (x % 2       !=  1)           print('6');
		if (-x          != -97)          print('7');
		if ( x << 2     != y * 4)        print('8');
		if ( x >> 1     != y / 2)        print('9');
		if ( (x & 1)     != 1)           print('a');
		if ( (x | 2)     != 99)          print('b');
		if ( (x ^ 1)     != 96)          print('c');
		if ( -x >>> 30   != 3)           print('d');

		if ( x <  0) print('e');
		if (-x >  0) print('f');
		if (-x >= 0) print('g');
		if ( x <= 0) print('h');

		if (x < y)    print('i');
		if (x > y)    print('j');
		if (x-1 >= y) print('k');
		if (x+1 <= y) print('l');
	}
}
