public class TTGen109 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1364527752, 'D' };
        char[] cArr = { 'a', 'b', 1, 2, '4', '"', 'i' };
        int r = 0;
        for (int i : iArr) {
            r += (i - iArr[2]);
        }
        for (char c : cArr) {
            if ((iArr[1] >= iArr[0])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 + 1);
            }
        }
        print(r);
    }
}
