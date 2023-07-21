public class TTGen79 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1345437444, 'h' };
        char[] cArr = { 'a', 'b', 1, 2, '`', '$', 'r' };
        int r = 0;
        for (int i : iArr) {
            r += (r - i2);
        }
        for (char c : cArr) {
            if ((iArr[5] >= iArr[4])) {
                int d = iArr[4];
                if (d != 0)
                    r += (d + 1);
            }
        }
        print(r);
    }
}
