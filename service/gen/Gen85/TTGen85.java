public class TTGen85 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -444979986, '_' };
        char[] cArr = { 'a', 'b', 1, 2, 'J', '[', 'x' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 / iArr[5]);
        }
        for (char c : cArr) {
            if ((iArr[5] >= iArr[1])) {
                int d = iArr[5];
                if (d != 0)
                    r += (r / 1);
            }
        }
        print(r);
    }
}
