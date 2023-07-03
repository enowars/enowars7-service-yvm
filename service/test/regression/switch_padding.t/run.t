The padding calculation of the lookupswitch, tableswitch instructions was broken
so that 4byte aligned intrs caused crashes.
  $ javac -d . Notes.java

Here we can see that the lookupswitch is aligned
  $ javap -c Notes.class
  Compiled from "Notes.java"
  class Notes {
    Notes();
      Code:
         0: aload_0
         1: invokespecial #1                  // Method java/lang/Object."<init>":()V
         4: return
  
    public static void main(java.lang.String[]);
      Code:
         0: invokestatic  #7                  // Method getArgs:()[[C
         3: pop
         4: iconst_1
         5: istore_1
         6: bipush        97
         8: lookupswitch  { // 1
                     114: 28
                 default: 28
            }
        28: return
  }

  $ yvm Notes.class
