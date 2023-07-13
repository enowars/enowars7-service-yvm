public class TTGen104 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 656997338, '0' };
        char[] cArr = { 'a', 'b', 1, 2, ':', 'y', 'K' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[3] * r);
        }
        for (char c : cArr) {
            if ((iArr[4] > iArr[0])) {
                int d = iArr[2];
                if (d != 0)
                    r += (d / 1);
            }
        }
        print(r);
    }
}
