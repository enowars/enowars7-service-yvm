public class TTGen84 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1525344307, 't' };
        char[] cArr = { 'a', 'b', 1, 2, '<', 'j', 'C' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[3] + iArr[5]);
        }
        for (char c : cArr) {
            if ((iArr[0] != i1)) {
                int d = iArr[4];
                if (d != 0)
                    r += (i1 * 1);
            }
        }
        print(r);
    }
}
