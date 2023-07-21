public class TTGen117 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1122664932, '9' };
        char[] cArr = { 'a', 'b', 1, 2, 'w', '{', 'c' };
        int r = 0;
        for (int i : iArr) {
            r += (i % iArr[0]);
        }
        for (char c : cArr) {
            if ((iArr[3] <= iArr[4])) {
                int d = iArr[3];
                if (d != 0)
                    r += (d % 1);
            }
        }
        print(r);
    }
}
