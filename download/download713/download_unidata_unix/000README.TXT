 
Installation instructions for DOWNLOAD Version 7.13
September 2005
 
 
 
To install DOWNLOAD on your system, follow these steps:

 
   1.  Decide which directory DOWNLOAD will reside in (or create
       a new directory just for DOWNLOAD). This can be done within
       the database environment:
             CREATE.FILE DIR DOWNLOAD.SOURCE            (Unidata)
             CREATE.FILE DLSOURCE 1                     (Universe)
 
 
   2.  "ftp" the files from the Cedarville site into your directory.
       You may copy a single compressed file such as:
             download_unidata_unix.tar
             -- or --
             download_unidata_windows.exe
       or copy all of the individual files in the related
       directory such as:
             download_unidata_unix
             -- or --
             download_unidata_windows
 
 
   3.  If you copied a compressed file rather than all of the
       individual files, you will need to extract the files.
 
       If you copied a Unix tar file, you can un-tar the file with
       a command like this at a Unix prompt:
             tar xvf download_unidata_unix.tar
 
       If you copied a Windows "exe" file, you can un-zip the file
       by running the file at a DOS prompt:
             download_unidata_windows.exe
 

   4.  If you have not already done so, make a VOC entry for the directory
       into which you have copied the DOWNLOAD files.
 
       If you are using remote accounts, make sure that the VOC
       entry for the DOWNLOAD source contains the full path to
       the directory.
 
       A typical entry for Unidata on Unix is something like this:
       AE VOC DOWNLOAD.SOURCE
       001: DIR
       002: /usr/local/DOWNLOAD.SOURCE
       003: /usr/local/D_DOWNLOAD.SOURCE

       Typical entries for Universe on Unix are something like this:
       AE VOC DLSOURCE
       001: F
       002: /usr/local/DLSOURCE
       003: /usr/local/D_DLSOURCE
       AE VOC DLSOURCE.O
       001: F
       002: /usr/local/DLSOURCE.O
       003: /usr/local/D_DLSOURCE.O

       For Universe, verify that you have a VOC entry for &HOLD&
       which would look like this:
       001: F
       002: &HOLD&
       003: D_&HOLD&
 
 
   5.  Copy the installation paragraph to the VOC:
         COPY FROM DOWNLOAD.SOURCE TO VOC BUILDDL.VOC   (Unidata)
         COPY FROM DLSOURCE TO VOC BUILDDLVOC           (Universe)


   6.  Run the installation paragraph.  This paragraph will compile and
       catalog all of the programs and subroutines used by DOWNLOAD.
       At the database prompt, enter:
         BUILDDL.VOC                                    (Unidata)
         BUILDDLVOC                                     (Universe)

       You will be prompted for the directory name containing the
       DOWNLOAD source-code files.  This is usually DOWNLOAD.SOURCE
       (Unidata) or DLSOURCE (Universe).
 
       You will also be prompted for the type of cataloging you
       want:
             LOCAL or DIRECT                            (Unidata)
             LOCAL or (null)                            (Universe)
       Cataloging with the LOCAL option will create VOC entries
       with the path names to the executables.  Cataloging globally
       will copy the executables to the global catalog space and
       create VOC entries pointing to that catalog space.  DOWNLOAD
       will work either way, so you can follow whatever is typical
       for other software used at your site.
 
       Some versions of Unidata or Universe will report a warning
       message for DOWNLOAD.OP.SYS.WRITE (or DLOSWRITE) that the
       variable "@ID" is never assigned a value.  This warning may
       be ignored (the variable does get a value; the compiler is
       confused).
 
 
   7.  DOWNLOAD is now installed on your system.  If you have any
       remote accounts which need to use DOWNLOAD, you will need to
       copy some VOC entries to those accounts.
 
       For Unidata, enter:
           FORM.LIST DOWNLOAD.SOURCE VOCLIST
           COPY FROM VOC TO xxx.REMOTE.VOC OVERWRITING
 
       For Universe, enter:
           FORM.LIST DLSOURCE VOCLIST
           COPY FROM VOC TO xxx.REMOTE.VOC OVERWRITING
 
       You may get a "not found" message for the following:
           PRIMOS...     Applicable only to Primos systems
 
 
   8.  To verify that you have completed a successful installation,
       do the following at the database prompt:
       a.  Create a test file.
             CREATE.FILE DOWNLOAD.TEST.FILE             (Unidata)
             CREATE.FILE DLTESTFILE                     (Universe)
           A modulo size of 1 is adequate for testing.
       b.  Populate the test file with data.
             DOWNLOAD.BUILD.TEST.FILE                   (Unidata)
             DLBUILDTEST                                (Universe)
       c.  Run several variations of DOWNLOAD.
             DOWNLOAD.TEST.PARAGRAPH                    (Unidata)
             DLTESTPARA                                 (Universe)
           The paragraph should produce three short reports on the
           screen and seven output files in the _HOLD_ (or &HOLD&)
           directory.
 
           Your results can be compared with the files found in:
             downloadtestresults.tar                    (Unix)
             -- or --
             downloadtestresults.exe                    (Windows)
 
           The test file may be deleted after you have verified
           the DOWNLOAD installation, as the test file is just
           that...it is not required for operation of DOWNLOAD.
 
 
If you have trouble running DOWNLOAD on a Unidata system, try
setting ECLTYPE to U rather than P (i.e., UDT.OPTIONS 2 OFF).
 
The following paragraphs are delivered with DOWNLOAD and can
be copied to your VOC file to assist with the installation:
    DLDELOBSCAT       delete obsolete catalog (and VOC) entries for
                      external subroutines which were renamed
                      at release 7.10
    DLDELCURCAT       delete catalog (and VOC) entries for
                      the current release of DOWNLOAD
Do not run DLDELOBSCAT if you have used the older DOWNLOAD
subroutines (like OPEN.FILE) in other programs on your system.
 
A full reference manual for DOWNLOAD is in the file 'download.pdf'.
A short help file will display to the screen if you just type
DOWNLOAD at the database prompt.
 
Typing DOWNLOAD HELP MAX at the database prompt will produce
a list of the limits (number of dictionary fields, literal
values, etc.) in effect for this version of DOWNLOAD.  These
can be changed by editing I_DOWNLOAD_MAX_COMMON and then
rebuilding DOWNLOAD via step 6 above.
 
The file DOWNLOAD.VER contains a list of changes made in recent
versions.  This list is also found in the PDF documentation file.
 
 
Informal support for DOWNLOAD can be obtained by posting queries
to an appropriate Internet list-serve:
 
  DOWNLOAD users
     send a message to:
         download-list-request@cedarville.edu
     with a subject line of "subscribe" (without the quotes)
 
  u2 users (Unidata and Universe users)
     send an empty message to:
        u2-users-subscribe@listserver.u2ug.org
 
  info-datatel (Datatel clients)
     send message "subscribe info-datatel" in the body to
        majordomo@datatel.com
 
 
DOWNLOAD was originally written for Prime Information.  The current
version is maintained on a Unidata system running HP-UX (Unix).
The installation procedure has been tested on:
     Unidata 6.1, Unix (Linux)
     Unidata 6.0, Windows (Win2000 Professional)
     Universe 10.0, Unix (Linux)
     Universe 10.0, Windows (Win2000 Professional)
Installation files are provided for Information (Primos) and
Unidata (VMS), but these installation files have not been verified.


Special note regarding WP50 and WP51 output:
These formats require writing bytes containing all zeroes.  This
is handled by setting OP.SYS.ZERO.CHAR in the main DOWNLOAD program.
The value is fetched at compile time under Unidata (via a GETENV call)
or by an actual assignment statement.  If you get an "invalid file format"
message when trying to open a merge file in Word or WordPerfect, try
changing OP.SYS.ZERO.CHAR.  Typical values are 0, 128, or 131.  Newer
versions of Universe and Unidata store this value in their config files.

 
If you have any questions about DOWNLOAD, please try one of the
lists above.  If that fails, send email to
Dave Rotman (rotmand@cedarville.edu).
 
