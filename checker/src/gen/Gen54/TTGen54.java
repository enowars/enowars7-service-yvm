public class TTGen54 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1063967354, '+' };
        char[] cArr = { 'a', 'b', 1, 2, 'T', ';', '9' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[2] << r);
        }
        for (char c : cArr) {
            if ((iArr[5] < iArr[0])) {
                int d = iArr[2];
                if (d != 0)
                    r += (i2 + 1);
            }
        }
        print(r);
    }
}
