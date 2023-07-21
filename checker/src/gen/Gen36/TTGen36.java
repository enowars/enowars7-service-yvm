public class TTGen36 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -710855843, 'Z' };
        char[] cArr = { 'a', 'b', 1, 2, '_', 'M', 'T' };
        int r = 0;
        for (int i : iArr) {
            r += (i << r);
        }
        for (char c : cArr) {
            if ((iArr[1] < iArr[5])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i1 % 1);
            }
        }
        print(r);
    }
}
