public class TTGen53 {
    static int i1;
    static int i2;
    static char c1;
    static char c2;
    static native void print(int x);

    public static void main(String[] args) {
        int[] iArr = { i1++, i2, 1, 2, -2017083340, 'l' };
        char[] cArr = { 'a', 'b', 1, 2, 'j', ',', '$' };
        int r = 0;
        for (int i : iArr) {
            r += (r >>> i);
        }
        for (char c : cArr) {
            if ((iArr[5] > i1)) {
                int d = iArr[5];
                if (d != 0)
                    r += (i2 % 1);
            }
        }
        print(r);
    }
}
