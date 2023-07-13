public class TTGen143 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -90023136, 'd' };
        char[] cArr = { 'a', 'b', 1, 2, '[', '6', 'u' };
        int r = 0;
        for (int i : iArr) {
            r += (r - i);
        }
        for (char c : cArr) {
            if ((iArr[5] != iArr[4])) {
                int d = iArr[2];
                if (d != 0)
                    r += (i1 * 1);
            }
        }
        print(r);
    }
}
