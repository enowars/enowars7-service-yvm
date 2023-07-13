public class TTGen42 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1061146362, '~' };
        char[] cArr = { 'a', 'b', 1, 2, 'z', 'N', 'P' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] >>> iArr[5]);
        }
        for (char c : cArr) {
            if ((iArr[0] == iArr[2])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i2 - 1);
            }
        }
        print(r);
    }
}
