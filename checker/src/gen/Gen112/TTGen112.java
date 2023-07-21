public class TTGen112 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 248362436, 'U' };
        char[] cArr = { 'a', 'b', 1, 2, 'M', '(', '6' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[0] % iArr[2]);
        }
        for (char c : cArr) {
            if ((iArr[1] < iArr[4])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i1 - 1);
            }
        }
        print(r);
    }
}
