public class TTGen100 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1357938715, 'f' };
        char[] cArr = { 'a', 'b', 1, 2, '\'', 'U', '_' };
        int r = 0;
        for (int i : iArr) {
            r += (i2 - i);
        }
        for (char c : cArr) {
            if ((i1 != iArr[2])) {
                int d = iArr[0];
                if (d != 0)
                    r += (i1 * 1);
            }
        }
        print(r);
    }
}
