#include <stdio.h>
#include <unistd.h>
#include "queue.h"

int qchown(i_cur_entry, i_queue_file, i_user_name, i_queue_name, i_job_number)
int i_cur_entry;
long i_queue_file;
char *i_user_name;
char *i_queue_name;
char *i_job_number;
{
   char temp_queue_name[16];
   short job_number;
   struct QUEUE_ENTRY q_entry;

   long cur_pos;
   size_t num_read;
   size_t num_written;
 

   job_number = atoi(i_job_number);
 
   cur_pos = i_cur_entry * ENTRY_SIZE;
   lseek(i_queue_file, cur_pos, SEEK_SET);
   if(lockf(i_queue_file, F_LOCK, ENTRY_SIZE)) {
      return(-1);
   }
   num_read = read(i_queue_file, &q_entry, sizeof(q_entry));
   if (num_read == 0)  {
      lseek(i_queue_file, cur_pos, SEEK_SET);
      lockf(i_queue_file, F_ULOCK, ENTRY_SIZE);
      return(-2);
   }
 
   strcpy(temp_queue_name, q_entry.queue_name);
   if (strcmp(temp_queue_name, i_queue_name) != 0)
      return(-3);
   if (q_entry.job_number != job_number)
      return(-4);
 
   strncpy(q_entry.user_name, i_user_name, 16);

   lseek(i_queue_file, cur_pos, SEEK_SET);
   num_written = write(i_queue_file, &q_entry, sizeof(q_entry));
   lseek(i_queue_file, cur_pos, SEEK_SET);
   lockf(i_queue_file, F_ULOCK, ENTRY_SIZE);
   return((int) num_written);
}
