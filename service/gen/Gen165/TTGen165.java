public class TTGen165 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -251985500, 'Q' };
        char[] cArr = { 'a', 'b', 1, 2, 'I', 'y', ',' };
        int r = 0;
        for (int i : iArr) {
            r += (i << i);
        }
        for (char c : cArr) {
            if ((iArr[5] != i2)) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 * 1);
            }
        }
        print(r);
    }
}
