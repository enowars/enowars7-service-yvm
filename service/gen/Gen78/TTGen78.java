public class TTGen78 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -2043613885, 'w' };
        char[] cArr = { 'a', 'b', 1, 2, '[', 'r', 'u' };
        int r = 0;
        for (int i : iArr) {
            r += (r - i1);
        }
        for (char c : cArr) {
            if ((iArr[2] > iArr[4])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i1 - 1);
            }
        }
        print(r);
    }
}
