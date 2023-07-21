public class TTGen138 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -334830514, 'H' };
        char[] cArr = { 'a', 'b', 1, 2, '`', '7', 'K' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] / i1);
        }
        for (char c : cArr) {
            if ((iArr[3] != i2)) {
                int d = iArr[2];
                if (d != 0)
                    r += (r + 1);
            }
        }
        print(r);
    }
}
