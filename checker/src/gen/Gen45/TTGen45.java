public class TTGen45 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1347319886, '-' };
        char[] cArr = { 'a', 'b', 1, 2, '$', '^', 'Z' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] << iArr[1]);
        }
        for (char c : cArr) {
            if ((iArr[3] != r)) {
                int d = iArr[5];
                if (d != 0)
                    r += (r * 1);
            }
        }
        print(r);
    }
}
