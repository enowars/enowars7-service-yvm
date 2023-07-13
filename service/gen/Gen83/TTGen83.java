public class TTGen83 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -135250626, 'q' };
        char[] cArr = { 'a', 'b', 1, 2, 'c', 's', 'o' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[5] >> iArr[4]);
        }
        for (char c : cArr) {
            if ((i2 == iArr[0])) {
                int d = iArr[3];
                if (d != 0)
                    r += (i2 % 1);
            }
        }
        print(r);
    }
}
