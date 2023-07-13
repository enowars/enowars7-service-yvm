public class TTGen137 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1649606141, 'D' };
        char[] cArr = { 'a', 'b', 1, 2, '-', '0', 'e' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[0] << iArr[5]);
        }
        for (char c : cArr) {
            if ((r <= iArr[3])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 - 1);
            }
        }
        print(r);
    }
}
