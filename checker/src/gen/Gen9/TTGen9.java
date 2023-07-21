public class TTGen9 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1368797851, 'b' };
        char[] cArr = { 'a', 'b', 1, 2, 'i', ':', 'I' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[4] >> i1);
        }
        for (char c : cArr) {
            if ((iArr[0] == iArr[2])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 % 1);
            }
        }
        print(r);
    }
}
