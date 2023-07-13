public class TTGen173 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, 786353488, '1' };
        char[] cArr = { 'a', 'b', 1, 2, ':', 'Q', 'L' };
        int r = 0;
        for (int i : iArr) {
            r += (i2 >>> iArr[1]);
        }
        for (char c : cArr) {
            if ((i2 >= iArr[1])) {
                int d = iArr[2];
                if (d != 0)
                    r += (d + 1);
            }
        }
        print(r);
    }
}
