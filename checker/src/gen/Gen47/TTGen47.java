public class TTGen47 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1815156866, 'i' };
        char[] cArr = { 'a', 'b', 1, 2, 'a', '\'', '0' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] * iArr[4]);
        }
        for (char c : cArr) {
            if ((iArr[1] == r)) {
                int d = iArr[0];
                if (d != 0)
                    r += (i1 * 1);
            }
        }
        print(r);
    }
}
