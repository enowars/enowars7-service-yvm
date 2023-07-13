public class TTGen89 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 811989560, '9' };
        char[] cArr = { 'a', 'b', 1, 2, '>', '.', '4' };
        int r = 0;
        for (int i : iArr) {
            r += (r - i);
        }
        for (char c : cArr) {
            if ((r != i1)) {
                int d = iArr[4];
                if (d != 0)
                    r += (i2 - 1);
            }
        }
        print(r);
    }
}
