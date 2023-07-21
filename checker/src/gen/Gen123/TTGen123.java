public class TTGen123 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 2090162388, 'l' };
        char[] cArr = { 'a', 'b', 1, 2, '6', 'T', 'D' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 + i);
        }
        for (char c : cArr) {
            if ((iArr[5] >= iArr[1])) {
                int d = iArr[0];
                if (d != 0)
                    r += (i1 / 1);
            }
        }
        print(r);
    }
}
