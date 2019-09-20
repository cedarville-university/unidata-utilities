#include <stdio.h>
#include "queue.h"

int qnext(i_last_entry, i_queue_file, o_node_name, o_user_name, o_queue_name, o_job_number,o_job_status)
int i_last_entry;
int i_queue_file;
char *o_node_name;
char *o_user_name;
char *o_queue_name;
char *o_job_number;
char *o_job_status;
{
   struct QUEUE_ENTRY q_entry;
   int cur_entry;
   long cur_pos;
   size_t num_read;
 
   cur_entry = i_last_entry;
   cur_pos = cur_entry * ENTRY_SIZE;
   lseek(i_queue_file, cur_pos, SEEK_SET);
   num_read = read(i_queue_file, &q_entry, sizeof(q_entry));
   strcpy(o_node_name, q_entry.node_name);
   strcpy(o_user_name, q_entry.user_name);
   strcpy(o_queue_name, q_entry.queue_name);
   sprintf(o_job_number, "%d", q_entry.job_number);
   sprintf(o_job_status, "%d", q_entry.job_status);
   if (num_read == 0) 
      return(-1);
   else
      return(cur_entry+1);
}
