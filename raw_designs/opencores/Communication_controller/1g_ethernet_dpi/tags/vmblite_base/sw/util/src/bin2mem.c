/****************************************************************************************** 
*   syntax: bin2mem  < filename1.bin  > filename2.mem
*   author: Rene van Leuken
*   modified: Tamar Kranenburg
*   February, 2008: header string provided, so ModelSim can recognize the file's format
*                   (= Veriloh hex) when 'Importing' into memory ... (Huib)
*   September, 2008: prevent reversing byte order
*
*******************************************************************************************/

#include <stdio.h>

main()
{
    unsigned char c1, c2, c3, c4;

    int i=0;
    while (!feof(stdin)) {
        c1 = getchar() & 0x0ff;
        c2 = getchar() & 0x0ff;
        c3 = getchar() & 0x0ff;
        c4 = getchar() & 0x0ff;

        if (i==0) {i++;} else {printf("\n");}

        printf ("%.2x%.2x%.2x%.2x", c1, c2, c3, c4);
    }

    return 0;
}
