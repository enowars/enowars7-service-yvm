public class TTGen25 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 430329470, 'u' };
        char[] cArr = { 'a', 'b', 1, 2, 'b', '7', '1' };
        int r = 0;
        for (int i : iArr) {
            r += (i2 >>> i1);
        }
        for (char c : cArr) {
            if ((iArr[0] > r)) {
                int d = iArr[4];
                if (d != 0)
                    r += (i1 % 1);
            }
        }
        print(r);
    }
}
