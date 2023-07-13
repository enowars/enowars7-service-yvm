public class TTGen71 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -605397780, 'T' };
        char[] cArr = { 'a', 'b', 1, 2, '>', '-', 'o' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[3] + i);
        }
        for (char c : cArr) {
            if ((i2 != iArr[3])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i2 + 1);
            }
        }
        print(r);
    }
}
