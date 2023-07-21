public class TTGen90 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1281560195, 'u' };
        char[] cArr = { 'a', 'b', 1, 2, '-', '|', 'Y' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 * iArr[2]);
        }
        for (char c : cArr) {
            if ((i1 <= iArr[2])) {
                int d = iArr[5];
                if (d != 0)
                    r += (d + 1);
            }
        }
        print(r);
    }
}
