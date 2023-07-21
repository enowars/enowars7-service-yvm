public class TTGen121 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -949527020, 'H' };
        char[] cArr = { 'a', 'b', 1, 2, '@', '|', 'O' };
        int r = 0;
        for (int i : iArr) {
            r += (i2 + iArr[4]);
        }
        for (char c : cArr) {
            if ((i1 > iArr[2])) {
                int d = iArr[2];
                if (d != 0)
                    r += (r + 1);
            }
        }
        print(r);
    }
}
