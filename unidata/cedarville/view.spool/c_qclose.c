#include <stdio.h>
 
int c_qclose(q_file)
long q_file;
{
   fclose((FILE *) q_file);
   return(1);
}
