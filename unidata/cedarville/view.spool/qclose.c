#include <stdio.h>
 
int qclose(q_file)
int q_file;
{
   return(close(q_file));
}
