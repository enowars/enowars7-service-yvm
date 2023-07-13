public class TTGen164 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 228484519, 'y' };
        char[] cArr = { 'a', 'b', 1, 2, 'b', 'i', '<' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 >> r);
        }
        for (char c : cArr) {
            if ((iArr[4] > iArr[3])) {
                int d = iArr[5];
                if (d != 0)
                    r += (d * 1);
            }
        }
        print(r);
    }
}
