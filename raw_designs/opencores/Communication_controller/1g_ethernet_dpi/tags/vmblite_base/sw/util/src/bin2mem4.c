/****************************************************************************************** 
*   syntax: bin2mem  < filename1.bin
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
    unsigned char c0, c1, c2, c3;

    FILE *fp0, *fp1, *fp2, *fp3;
    fp0=fopen("rom0.mem", "wb");
    fp1=fopen("rom1.mem", "wb");
    fp2=fopen("rom2.mem", "wb");
    fp3=fopen("rom3.mem", "wb");

    int i=0;
    while (!feof(stdin)) {
        c0 = getchar() & 0x0ff;
        c1 = getchar() & 0x0ff;
        c2 = getchar() & 0x0ff;
        c3 = getchar() & 0x0ff;

        if (i==0) {i++;} else {
            fprintf (fp0, "\n");
            fprintf (fp1, "\n");
            fprintf (fp2, "\n");
            fprintf (fp3, "\n");
        }

        fprintf (fp0, "%.2x", c3);
        fprintf (fp1, "%.2x", c2);
        fprintf (fp2, "%.2x", c1);
        fprintf (fp3, "%.2x", c0);
    }

    return 0;
}
