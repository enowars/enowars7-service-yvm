public class TTGen58 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 861302850, 'f' };
        char[] cArr = { 'a', 'b', 1, 2, '[', 'A', 'd' };
        int r = 0;
        for (int i : iArr) {
            r += (r >> iArr[5]);
        }
        for (char c : cArr) {
            if ((i1 != iArr[5])) {
                int d = iArr[4];
                if (d != 0)
                    r += (i1 / 1);
            }
        }
        print(r);
    }
}
