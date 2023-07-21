public class TTGen154 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 144605296, 'X' };
        char[] cArr = { 'a', 'b', 1, 2, '(', 'G', 'n' };
        int r = 0;
        for (int i : iArr) {
            r += (r >>> iArr[3]);
        }
        for (char c : cArr) {
            if ((iArr[0] >= r)) {
                int d = iArr[3];
                if (d != 0)
                    r += (r / 1);
            }
        }
        print(r);
    }
}
