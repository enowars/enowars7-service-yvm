public class TTGen46 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 225547046, 'Z' };
        char[] cArr = { 'a', 'b', 1, 2, 'D', 'X', '\'' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 * iArr[1]);
        }
        for (char c : cArr) {
            if ((i2 < iArr[4])) {
                int d = iArr[3];
                if (d != 0)
                    r += (r - 1);
            }
        }
        print(r);
    }
}
