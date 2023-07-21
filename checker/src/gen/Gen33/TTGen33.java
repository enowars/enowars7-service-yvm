public class TTGen33 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1394582534, '7' };
        char[] cArr = { 'a', 'b', 1, 2, '5', 'S', '?' };
        int r = 0;
        for (int i : iArr) {
            r += (r - iArr[3]);
        }
        for (char c : cArr) {
            if ((iArr[5] >= iArr[4])) {
                int d = iArr[0];
                if (d != 0)
                    r += (i2 - 1);
            }
        }
        print(r);
    }
}
