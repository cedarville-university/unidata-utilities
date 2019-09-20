/*
  Program: chqown.c
  Date...: 08/03/94
 
  Purpose:
    This program is necessary to change the owner of a lp queue job.  Only
    the owner (the user name stored in the outputq file) and root can change
    certain characteristics of the job.
 
    Complicating this is that in order to write back out the queue entry,
    the user needs write access.  Our users are already in the LP group, so
    we need to give group write access to the file outputq.  Everytime lp
    modifies the queue, the permissions get set back to group read only.
    So for the function qchown.c to do it's job it does:
       1. chmod 664 /usr/spool/lp/outputq
       2. locks the record for the entry
       3. rereads the entry
       4. changes the entry
       5. writes the entry
       6. unlocks the record
 
    Also, in order for the chmod function to work, this program must have
    special rights (since the user can not use the chmod by itself.)  After
    compiling this program, root must issue the following 2 commands:
       1. chown lp:lp chqown
       2. chmod u+s chqown
    which says, make lp the owner of the program, and let the program assume
    then owners security when it is run (so this program acts as if it is
    the user lp, so it can do the chmod & the write)
 
*/
 
#include <stdio.h>

int main(argc, argv)
int argc;
char **argv;
{
   short job_status;
   int numwritten;
   int next_ctr;
   int cur_ctr;
   char q_node[40];
   char q_user[40];
   char q_name[40];
   char q_job_number[8];
   char q_job_status[8];
   int q_file;
   char entry_queue[32];
   char *entry_job;
   char new_owner[16];
   int match;
   char outputq_name[40];
   strcpy(outputq_name, "/usr/spool/lp/outputq");
   if(argc != 3) {
      printf("\nSyntax:\n\n");
      printf("  cho queue-entry new-owner\n\n");
      printf("Eg.\n");
      printf("  cho hold-135 jonesp\n\n");
      exit(-1);
   } 
   match = 0;
 
   strncpy(entry_queue, argv[1], 32);
   strncpy(new_owner, argv[2], 16);
   entry_job = strchr(entry_queue, '-');
   if(entry_job == 0) {
      printf("Invalid entry name: %s\n", entry_queue);
      exit(-2);
   }

   *entry_job = '\0';
   entry_job += 1;
  
   q_file = qopen(outputq_name);
   if (q_file < 0) {
      printf("Can not open %s\n", outputq_name);
      exit(-3);
   }
   cur_ctr = 0;
   next_ctr = qnext(cur_ctr, q_file, q_node, q_user, q_name, q_job_number, q_job_status);
   while((next_ctr != -1) && (match == 0)) {
      job_status = atoi(q_job_status);
      if((job_status & 1) == 0) {  
         if ((strcmp(entry_queue, q_name) == 0) && (strcmp(entry_job,q_job_number) == 0)) {
            numwritten = qchown(cur_ctr, q_file, new_owner, entry_queue, entry_job);
            if (numwritten == 0) {
               printf("Can not change entry: %s-%s\n", entry_queue, entry_job);
               exit(-4);
            }
            match = 1;
         }
      }
      cur_ctr = next_ctr;
      next_ctr = qnext(cur_ctr, q_file, q_node, q_user, q_name, q_job_number, q_job_status);
   }
   qclose(q_file);
   if (!match) {
      printf("Job %s-%s not found.\n", entry_queue, entry_job);
      exit(-5);
   }
   exit();
}
