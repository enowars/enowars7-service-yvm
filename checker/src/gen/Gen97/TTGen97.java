public class TTGen97 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 946568887, '!' };
        char[] cArr = { 'a', 'b', 1, 2, ']', 'k', 'l' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] >>> i2);
        }
        for (char c : cArr) {
            if ((i2 < iArr[2])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 * 1);
            }
        }
        print(r);
    }
}
