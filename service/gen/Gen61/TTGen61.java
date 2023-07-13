public class TTGen61 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 744348850, '6' };
        char[] cArr = { 'a', 'b', 1, 2, 'Q', 'w', '"' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] + i1);
        }
        for (char c : cArr) {
            if ((i1 > iArr[0])) {
                int d = iArr[4];
                if (d != 0)
                    r += (r + 1);
            }
        }
        print(r);
    }
}
