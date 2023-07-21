public class TTGen21 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -143707445, 'P' };
        char[] cArr = { 'a', 'b', 1, 2, 'v', 'J', 'h' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] * r);
        }
        for (char c : cArr) {
            if ((iArr[2] >= i2)) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 + 1);
            }
        }
        print(r);
    }
}
