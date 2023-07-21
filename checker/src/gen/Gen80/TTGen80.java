public class TTGen80 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1041912412, '8' };
        char[] cArr = { 'a', 'b', 1, 2, 'P', '}', '+' };
        int r = 0;
        for (int i : iArr) {
            r += (i >> i1);
        }
        for (char c : cArr) {
            if ((r <= iArr[1])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i1 / 1);
            }
        }
        print(r);
    }
}
