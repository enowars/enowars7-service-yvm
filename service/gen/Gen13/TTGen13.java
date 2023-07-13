public class TTGen13 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -598495892, 'K' };
        char[] cArr = { 'a', 'b', 1, 2, 'k', ',', 'x' };
        int r = 0;
        for (int i : iArr) {
            r += (i1 >>> i1);
        }
        for (char c : cArr) {
            if ((iArr[1] <= iArr[3])) {
                int d = iArr[0];
                if (d != 0)
                    r += (d * 1);
            }
        }
        print(r);
    }
}
