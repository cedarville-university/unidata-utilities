#define ENTRY_SIZE 332

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
};
