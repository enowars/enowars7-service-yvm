class Foo {

	native static void print(char c);

	static void do_switch(int i) {
		switch (i) {
			case 8:
				print('n');
				break;
			case 9:
				print('a');
				break;
			case 10:
				print('i');
				break;
			default:
				print('s');
				break;
		}
	}

	public static void main(String[] args) {
		do_switch(8);
		do_switch(9);
		do_switch(10);
		do_switch(3);
	}
}
