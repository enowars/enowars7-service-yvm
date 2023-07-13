public class TTGen151 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1733923551, '\'' };
        char[] cArr = { 'a', 'b', 1, 2, 'H', 'P', '"' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] % i1);
        }
        for (char c : cArr) {
            if ((i1 > iArr[0])) {
                int d = iArr[4];
                if (d != 0)
                    r += (d + 1);
            }
        }
        print(r);
    }
}
