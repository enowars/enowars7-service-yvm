public class TTGen128 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 271828669, ']' };
        char[] cArr = { 'a', 'b', 1, 2, 'A', 'V', 'r' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 << i2);
        }
        for (char c : cArr) {
            if ((i2 >= iArr[1])) {
                int d = iArr[5];
                if (d != 0)
                    r += (i2 - 1);
            }
        }
        print(r);
    }
}
