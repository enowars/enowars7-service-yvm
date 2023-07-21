public class TTGen102 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -364303766, '6' };
        char[] cArr = { 'a', 'b', 1, 2, 'J', 'i', 'j' };
        int r = 0;
        for (int i : iArr) {
            r += (iArr[1] - r);
        }
        for (char c : cArr) {
            if ((iArr[1] != iArr[2])) {
                int d = iArr[5];
                if (d != 0)
                    r += (r * 1);
            }
        }
        print(r);
    }
}
