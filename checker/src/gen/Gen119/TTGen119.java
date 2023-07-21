public class TTGen119 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1343959715, '0' };
        char[] cArr = { 'a', 'b', 1, 2, '|', 'u', 'a' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[0] >> iArr[0]);
        }
        for (char c : cArr) {
            if ((i1 < iArr[3])) {
                int d = iArr[2];
                if (d != 0)
                    r += (d % 1);
            }
        }
        print(r);
    }
}
