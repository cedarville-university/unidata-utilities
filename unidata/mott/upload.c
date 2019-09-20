/*
  Upload V1.1
  Michael A. Bobbitt
  (army@izzy.net)

  Upload takes a flat ascii file and "uploads" it into a UniData file.

  Example:
  upload -tUN.DESCS -a cc2.txt -p/datatel/work/coltest -dT

  Loads from the flat file cc2.txt, which is tab delimited, into UN.DESCS
  in the /datatel/work/coltest account.
*/
/*
  INCLUDES
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
  DEFINES
*/

#define MAX 2000

/*
  PROTOTYPE DECLARATIONS
*/

void error(char *s);
void main(int argc,char *argv[]);

/*
  FUNCTIONS
*/

void error(char *s)
{
  printf("\n\nERROR: %s\n\nExecution Terminated.\n\n",s);
  exit(1);
}

void main(int argc,char *argv[])
{
FILE *in,*out;
char s[MAX+1],fd[300],fn[100],ufn[100],acct[100],delim;
int x,y,fl,rec;
long fld;
  /* Display Banner */
  printf("\nupload V1.1");
  printf("\n\nWritten By Mike Bobbitt");
  printf("\n\nupload takes an ASCII flat file and uploads it to a UniData file.");
  printf("\n\nCommand Line Parameters:");
  printf("\n-p Path_To_UniData_Account");
  printf("\n-t UniData_Target_File");
  printf("\n-a ASCII_File");
  printf("\n-d delimiter   (-dT for tab delimiters)");

  /* Set default values */
  strcpy(acct,"");
  strcpy(ufn,"");
  strcpy(fn,"");
  delim=-2;

  /* Strip out comand line parameters */
  for (x=1;x<=argc;x++)
  {
    if (argv[x][0]=='-')
    {
      if (strlen(argv[x])==2)
      {
        x++;
        strcpy(s,argv[x]);
        y=1;
      }
      else
      {
        for (y=2;y<strlen(argv[x]);y++)
          s[y-2]=argv[x][y];
        s[y-2]=0;
        y=0;
      }
      switch (argv[x-y][1])
      {
        case 'p':
          strcpy(acct,s);
          break;
        case 't':
          strcpy(ufn,s);
          break;
        case 'a':
          strcpy(fn,s);
          break;
        case 'd':
        /* T = Tab */
          if (!strcmp(s,"T"))
            s[0]=9;
          delim=s[0];
          break;
        default:
          strcpy(fn,"Invalid Command Line Parameter: ");
          strcat(fn,argv[x]);
          error(fn);
          break;
      }
    }
  }

  /*
    If values weren't passed as command line parameters, prompt for
    them now
  */
  if (!strlen(acct))
  {
    printf("\n\nEnter the path to the UniData account are you uploading to.");
    printf("\n(IE:/datatel/work/coltest): ");
    scanf("%s",&acct);
  }
  if (!strlen(fn))
  {
    printf("\n\nWhat is the name of the file you are uploading from? ");
    scanf("%s",&fn);
  }
  if (!strlen(ufn))
  {
    printf("\n\nNOTE: The UniData file must already exist for the account you're");
    printf("\nuploading to!");
    printf("\n\nWhat is the UniData file name you're uploading to ? ");
    scanf("%s",&ufn);
  }

  /* Display settings */
  printf("\n\nTarget Account Path:      %s",acct);
  printf("\nTarget File:                %s",ufn);
  printf("\nSource ASCII File:          %s",fn);

  /* Open files */
  if((in=fopen(fn,"r")) == NULL)
  {
    strcpy(fd,"Cannot Open ");
    strcat(fd,fn);
    strcat(fd,"!");
    error(fd);
  }
  if((out=fopen("upload.dat","w")) == NULL)
    error("Cannot Create upload.dat!");

  /* Write instructions to upload */
  fprintf(out,"AE %s\n",ufn);
  fld=rec=0;
  while (fgets(s,MAX,in)!=NULL)
  {
    s[strlen(s)-1]=0;
    rec++;
    fl=1;
    for (y=x=0;x<=strlen(s);x++,y++)
    {
      if ((s[x]!=delim) && (s[x]!=0))
        fd[y]=s[x];
      else
      {
        fld++;
        fd[y]=0;
        if (!y)
          fprintf(out,"`\n");
        else
          fprintf(out,"%s\n",fd);
        if (fl)
        {
          fl=0;
          fprintf(out,"D999\nI\n");
        }
        y=-1;
      }
    }
    fprintf(out,"\nTRIMA\nFI\n");
  }
  fprintf(out,"\nQUIT\n");

  /* Close Files */
  fclose(in);
  fclose(out);

  /* Show upload info */
  printf("\n\n%d Records Processed.",rec);
  printf("\n\n%d Fields Processed.",fld);
  printf("\n\nAverage of %d Fields per Record.",fld/rec);

  /* Prompt for upload */
  printf("\n\nUpload now? ");
  x=getchar();
  y=getchar();
  if ((x=='y') || (x=='Y'))
  {
    printf("\n\nUploading...");
    strcpy(s,"cp upload.dat /tmp");
    printf(".");
    system(s);
    printf(".");
    chdir(acct);
    printf(".");
    strcpy(s,"cat /tmp/upload.dat | udt > /dev/null");
    printf(".");
    system(s);
    printf(".Done!\n");
  }
  printf("\n");
}
