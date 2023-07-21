public class TTGen86 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1403437448, '^' };
        char[] cArr = { 'a', 'b', 1, 2, '-', 'J', '~' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] + i);
        }
        for (char c : cArr) {
            if ((iArr[5] >= iArr[3])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i1 / 1);
            }
        }
        print(r);
    }
}
