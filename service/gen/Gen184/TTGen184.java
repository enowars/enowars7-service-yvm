public class TTGen184 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1942207513, 'a' };
        char[] cArr = { 'a', 'b', 1, 2, 'J', 'q', 'd' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] >>> r);
        }
        for (char c : cArr) {
            if ((iArr[2] < iArr[0])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 % 1);
            }
        }
        print(r);
    }
}
