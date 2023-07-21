public class TTGen168 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -923934623, 'v' };
        char[] cArr = { 'a', 'b', 1, 2, 'B', '7', '=' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[3] / iArr[4]);
        }
        for (char c : cArr) {
            if ((iArr[4] <= iArr[3])) {
                int d = iArr[2];
                if (d != 0)
                    r += (d % 1);
            }
        }
        print(r);
    }
}
