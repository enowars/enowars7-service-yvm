public class TTGen107 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -450030113, 'c' };
        char[] cArr = { 'a', 'b', 1, 2, 'X', '=', 'x' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] * i2);
        }
        for (char c : cArr) {
            if ((i2 != iArr[2])) {
                int d = iArr[3];
                if (d != 0)
                    r += (r + 1);
            }
        }
        print(r);
    }
}
