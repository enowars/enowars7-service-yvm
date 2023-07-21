public class TTGen187 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 496996977, '^' };
        char[] cArr = { 'a', 'b', 1, 2, '_', ']', 'q' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[2] << r);
        }
        for (char c : cArr) {
            if ((i2 != r)) {
                int d = iArr[2];
                if (d != 0)
                    r += (r + 1);
            }
        }
        print(r);
    }
}
