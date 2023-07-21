class Notes {

	private static char[] errorMkdir = {'e', 'r', 'r', 'o', 'r', ':', ' ', 'm', 'k', 'd', 'i', 'r'};
	private static char[] errorLs    = {'e', 'r', 'r', 'o', 'r', ':', ' ', 'l', 's'};
	private static char[] errorWrite = {'e', 'r', 'r', 'o', 'r', ':', ' ', 'w', 'r', 'i', 't', 'e'};
	private static char[] errorRead  = {'e', 'r', 'r', 'o', 'r', ':', ' ', 'r', 'e', 'a', 'd'};

	private native static char[][] getArgs();

	private native static char[] getToken();

	private native static boolean mkdir(char[] dir);

	private native static char[][] ls(char[] dir);

	private native static void print(char[] arg);

	private native static void error(char[] arg);

	private native static boolean write(char[] file, char[] content);

	private native static char[] read(char[] file);

	private static void register() {
		char[] t = getToken();
		if (mkdir(t)) {
			print(t);
		} else {
			error(errorMkdir);
		}
	}

	private static void listNotes(char[] token) {
		char[][] notes = ls(token);
		if (notes == null) {
			error(errorLs);
			return;
		}
		for (char[] note : notes) {
			print(note);
		}
	}

	private static char[] toPath(char[] token, char [] name) {
		char[] path = new char[token.length + 1 + name.length];
		for (int i = 0; i < token.length; i++) {
			path[i] = token[i];
		}
		path[token.length] = '/';
		for (int i = 0; i < name.length; i++) {
			path[i + token.length + 1] = name[i];
		}
		return path;
	}

	private static void addNote(char[] token, char[] name, char[] content) {
		char[] path = toPath(token, name);
		if (!write(path, content)) {
			error(errorWrite);
			return;
		}
	}

	private static void getNote(char[] token, char[] name) {
		char[] path = toPath(token, name);
		char[] r = read(path);
		if (r == null) {
			error(errorRead);
			return;
		}
		print(r);
	}

	public static void main(String[] _args) {
		char[][] args = getArgs();
		char cmd = args[0][0];
		switch (cmd) {
			case 'r':
				register();
				break;
			case 'l':
				listNotes(args[1]);
				break;
			case 'a':
				addNote(args[1], args[2], args[3]);
				break;
			case 'g':
				getNote(args[1], args[2]);
				break;
		}
	}
}
