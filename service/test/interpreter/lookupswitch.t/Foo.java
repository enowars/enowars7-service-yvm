class Foo {

	native static void print(char c);

	static void do_switch(int i) {
		switch (i) {
			case 0:
				print('n');
				break;
			case 1:
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
		do_switch(0);
		do_switch(1);
		do_switch(10);
		do_switch(3);
	}
}
