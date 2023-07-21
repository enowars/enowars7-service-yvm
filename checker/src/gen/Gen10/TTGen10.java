public class TTGen10 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1645442202, 'o' };
        char[] cArr = { 'a', 'b', 1, 2, '<', ' ', 'o' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[2] / iArr[2]);
        }
        for (char c : cArr) {
            if ((r == iArr[0])) {
                int d = iArr[2];
                if (d != 0)
                    r += (r * 1);
            }
        }
        print(r);
    }
}
