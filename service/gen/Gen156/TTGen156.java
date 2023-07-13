public class TTGen156 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -622892406, 'a' };
        char[] cArr = { 'a', 'b', 1, 2, 'v', '"', 's' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[0] >> iArr[2]);
        }
        for (char c : cArr) {
            if ((r != iArr[2])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 % 1);
            }
        }
        print(r);
    }
}
