#include <stdio.h>
#define ENTRY_SIZE 332

int c_qnext(i_last_entry, i_queue_file, o_node_name, o_user_name, o_queue_name, o_job_number,o_job_status)
int i_last_entry;
long i_queue_file;
char *o_node_name;
char *o_user_name;
char *o_queue_name;
char *o_job_number;
char *o_job_status;
{
   struct QUEUE_ENTRY {
      char filler1[14];
      short job_number;
      short job_status;
      char filler2[4];
      char node_name[16];
      char filler3[244];
      char user_name[16];
      char queue_name[16];
      char queue_printed[16];
      char filler4[2];
   } q_entry;

   FILE *q_file;
   int cur_entry;
   long cur_pos;
   size_t num_read;
 
   q_file = (FILE *) i_queue_file;
   cur_entry = i_last_entry;
   cur_pos = cur_entry * ENTRY_SIZE;
   fseek(q_file, cur_pos, SEEK_SET);
   num_read = fread(&q_entry, sizeof(q_entry), 1, q_file);
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
