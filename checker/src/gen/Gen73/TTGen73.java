public class TTGen73 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 695031411, 'c' };
        char[] cArr = { 'a', 'b', 1, 2, ':', '#', '[' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[0] / iArr[4]);
        }
        for (char c : cArr) {
            if ((i1 > iArr[2])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 / 1);
            }
        }
        print(r);
    }
}
