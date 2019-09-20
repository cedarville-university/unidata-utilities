#include <stdio.h>
#include <fcntl.h>
#include <sys/stat.h>
 
int qopen(i_file_name)
char *i_file_name;
{
   chmod(i_file_name, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH);
   return(open(i_file_name, O_RDWR));
}
