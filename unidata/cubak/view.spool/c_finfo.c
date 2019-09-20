#include <stdio.h>
#include <time.h>
#include <sys/stat.h>
 
int c_finfo(i_file_name, o_buffer)
char *i_file_name;
char *o_buffer;
{
   struct stat statbuf;
   struct tm *mtimebuf;
   struct tm *ctimebuf;
   struct tm *atimebuf;
   int status;
   char FM;
 
   FM = (char) 254;
 
   status = stat(i_file_name, &statbuf);
   if(!status) {
      mtimebuf = localtime(&(statbuf.st_mtime));
      atimebuf = localtime(&(statbuf.st_atime));
      ctimebuf = localtime(&(statbuf.st_ctime));
      sprintf(o_buffer, "%u%c%d%c%02d/%02d/%02d%c%02d/%02d/%02d%c%02d/%02d/%02d%c%02d:%02d:%02d%c%02d:%02d:%02d%c%02d:%02d:%02d",
         statbuf.st_mode, FM, statbuf.st_size, FM,
         atimebuf->tm_mon+1, atimebuf->tm_mday, atimebuf->tm_year, FM,
         mtimebuf->tm_mon+1, mtimebuf->tm_mday, mtimebuf->tm_year, FM,
         ctimebuf->tm_mon+1, ctimebuf->tm_mday, ctimebuf->tm_year, FM,
         atimebuf->tm_hour, atimebuf->tm_min, atimebuf->tm_sec, FM,
         mtimebuf->tm_hour, mtimebuf->tm_min, mtimebuf->tm_sec, FM,
         ctimebuf->tm_hour, ctimebuf->tm_min, ctimebuf->tm_sec);
   }
   return(status);
}
