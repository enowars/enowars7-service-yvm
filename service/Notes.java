import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.BufferedWriter;

class Notes {

	private static char[] errorMsg = {'e', 'r', 'r', 'o', 'r'};

	private static char[] getToken() {
		return "foobar".toCharArray();
	}

	private static boolean mkdir(char[] dir) {
		return new File(new String(dir)).mkdir();
	}

	private static char[][] ls(char[] dir) {
		String[] files = new File(new String(dir)).list();
		char[][] cfiles = new char[files.length][];
		for (int i = 0; i < files.length; i++) {
			cfiles[i] = files[i].toCharArray();
		}
		return cfiles;
	}

	private static void print(char[] arg) {
		System.out.println(arg);
	}

	private static boolean write(char[] file, char[] content) {
		// TODO write once!!
		try {
			BufferedWriter writer = new BufferedWriter(new FileWriter(new String(file)));
			writer.write(new String(content));
			writer.close();
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	private static char[] read(char[] file) {
		StringBuilder resultStringBuilder = new StringBuilder();
		try (BufferedReader br = new BufferedReader(new FileReader(new String(file)))) {
			String line;
			while ((line = br.readLine()) != null) {
				resultStringBuilder.append(line).append("\n");
			}
		} catch (Exception e) {
			return null;
		}
		return resultStringBuilder.toString().toCharArray();
	}

	private static void register() {
		char[] t = getToken();
		if (mkdir(t)) {
			print(t);
		} else {
			print(errorMsg);
		}
	}

	private static void listNotes(char[] token) {
		for (char[] note : ls(token)) {
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
		write(path, content);
	}

	private static void getNote(char[] token, char[] name) {
		char[] path = toPath(token, name);
		print(read(path));
	}

	public static void run(char[][] args) {
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

	public static void main(String[] args) {
		char[][] cargs = new char[args.length][];
		for (int i = 0; i < args.length; i++) {
			cargs[i] = args[i].toCharArray();
		}
		run(cargs);
	}
}
