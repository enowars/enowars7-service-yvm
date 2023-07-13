public class TTGen116 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -723795025, '#' };
        char[] cArr = { 'a', 'b', 1, 2, 'i', 'K', '2' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[4] >> r);
        }
        for (char c : cArr) {
            if ((i2 >= iArr[4])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 + 1);
            }
        }
        print(r);
    }
}
