public class TTGen96 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -195919635, '=' };
        char[] cArr = { 'a', 'b', 1, 2, '.', '+', '{' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] % i1);
        }
        for (char c : cArr) {
            if ((iArr[5] > i2)) {
                int d = iArr[4];
                if (d != 0)
                    r += (d + 1);
            }
        }
        print(r);
    }
}
