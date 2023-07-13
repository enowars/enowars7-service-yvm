public class TTGen4 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1276330397, '+' };
        char[] cArr = { 'a', 'b', 1, 2, 'C', '\'', 'X' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] * iArr[0]);
        }
        for (char c : cArr) {
            if ((i2 <= i1)) {
                int d = iArr[0];
                if (d != 0)
                    r += (i1 - 1);
            }
        }
        print(r);
    }
}
