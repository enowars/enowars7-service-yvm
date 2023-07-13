public class TTGen124 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -2061001077, 'd' };
        char[] cArr = { 'a', 'b', 1, 2, '=', '\\', '8' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[4] << iArr[3]);
        }
        for (char c : cArr) {
            if ((r >= i1)) {
                int d = iArr[5];
                if (d != 0)
                    r += (i1 - 1);
            }
        }
        print(r);
    }
}
