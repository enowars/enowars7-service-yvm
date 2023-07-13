public class TTGen200 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 1031932748, '#' };
        char[] cArr = { 'a', 'b', 1, 2, 'J', 'k', 'W' };
        int r = 0;
        for (int i : iArr) {
            r += (i + iArr[0]);
        }
        for (char c : cArr) {
            if ((iArr[4] > iArr[1])) {
                int d = iArr[0];
                if (d != 0)
                    r += (d - 1);
            }
        }
        print(r);
    }
}
