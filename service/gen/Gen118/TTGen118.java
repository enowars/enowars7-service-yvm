public class TTGen118 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 5873719, 'D' };
        char[] cArr = { 'a', 'b', 1, 2, 'P', 'G', 'q' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 * iArr[3]);
        }
        for (char c : cArr) {
            if ((iArr[0] != i1)) {
                int d = iArr[0];
                if (d != 0)
                    r += (r % 1);
            }
        }
        print(r);
    }
}
