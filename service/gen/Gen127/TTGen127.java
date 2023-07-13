public class TTGen127 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1149768175, 'z' };
        char[] cArr = { 'a', 'b', 1, 2, '&', 'm', 'v' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[2] >> iArr[3]);
        }
        for (char c : cArr) {
            if ((iArr[2] != i2)) {
                int d = iArr[5];
                if (d != 0)
                    r += (d * 1);
            }
        }
        print(r);
    }
}
