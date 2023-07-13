public class TTGen163 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -1509586263, '{' };
        char[] cArr = { 'a', 'b', 1, 2, '4', 'z', ';' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] >> iArr[3]);
        }
        for (char c : cArr) {
            if ((iArr[4] <= i2)) {
                int d = iArr[4];
                if (d != 0)
                    r += (d / 1);
            }
        }
        print(r);
    }
}
