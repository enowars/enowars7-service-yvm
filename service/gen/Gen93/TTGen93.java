public class TTGen93 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1833682560, 'U' };
        char[] cArr = { 'a', 'b', 1, 2, 'T', 'Y', 'A' };
        int r = 0;
        for (int i : iArr) {
            r += (i >>> iArr[4]);
        }
        for (char c : cArr) {
            if ((iArr[3] != iArr[1])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i1 + 1);
            }
        }
        print(r);
    }
}
