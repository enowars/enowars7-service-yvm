public class TTGen111 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1522000988, 'r' };
        char[] cArr = { 'a', 'b', 1, 2, 'o', '"', 'm' };
        int r = 0;
        for (int i : iArr) {
            r += (i / iArr[5]);
        }
        for (char c : cArr) {
            if ((iArr[2] != iArr[0])) {
                int d = iArr[3];
                if (d != 0)
                    r += (d * 1);
            }
        }
        print(r);
    }
}
