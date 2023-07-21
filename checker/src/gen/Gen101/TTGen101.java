public class TTGen101 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1518699259, 'o' };
        char[] cArr = { 'a', 'b', 1, 2, 'q', 'n', '6' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] >> iArr[3]);
        }
        for (char c : cArr) {
            if ((i1 != r)) {
                int d = iArr[5];
                if (d != 0)
                    r += (r - 1);
            }
        }
        print(r);
    }
}
