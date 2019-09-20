#include <stdio.h>
 
long c_qopen(i_file_name)
char *i_file_name;
{
   FILE *q_file;
 
   q_file = fopen(i_file_name, "rb+");
   return((long) q_file);
}
