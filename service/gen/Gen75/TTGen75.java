public class TTGen75 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -96247141, 'x' };
        char[] cArr = { 'a', 'b', 1, 2, 'n', 'R', 'N' };
        int r = 0;
        for (int i : iArr) {
            r += (r / iArr[2]);
        }
        for (char c : cArr) {
            if ((iArr[2] != i1)) {
                int d = iArr[5];
                if (d != 0)
                    r += (i1 * 1);
            }
        }
        print(r);
    }
}
