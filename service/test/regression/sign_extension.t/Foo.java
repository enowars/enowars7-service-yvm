public class Foo {
	static int x = 97;

	public static void main(String[] args) {
		// bipush of negative value
		if (-x != -97) {
			x = 1 / (x - x);
		}
		int l = 0;
		// negative iinc
		if (--l != -1) {
			x = 1 / (x - x);
		}
	}
}
