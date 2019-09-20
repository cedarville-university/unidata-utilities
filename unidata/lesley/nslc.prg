945 LINES
*-------------------------- FTP SUBMISSION FORM --------------------------
*--- PROGRAM NAME...: NSLC.DOWNLOAD.PROCESS
*--- 40-CHAR DESC...: For creating ascii file to transmit to NSLC
*--- KEYWORDS.......:
*--- SUBMISSION DATE: 4 January 1996
*--- COMPANY NAME...: Lesley College
*--- CONTACT NAME...: Scott T. Boulet
*--- CONTACT PHONE#.: 617.349.8610
*--- CONTACT EMAIL..: sboulet@mail.lesley.edu
*--- LONG DESC......: This program reads colleague data to build an ascii
*---                : file for transmission to National Stud. Loan
*---                : clearinghouse.
*---                :
*---                :
*-------------------------------------------------------------------------
FILE/RECORD INFORMATION:
  1 NSLC.DOWNLOAD.PROCESS.............. NSLC.DOWNLOAD.PROCESS         
 ##### FILE NSLC.DOWNLOAD.PROCESS #################    1 RECORDS ######
 ======== RECORD NSLC.DOWNLOAD.PROCESS ============   894 FIELDS ======
 *
 * UNIBASIC PROGRAM
 * 28 August 1995
 * Scott T. Boulet
 * NSLC.DOWNLOAD.PROCESS
 * 12.3
 * Project # 466
 *
 * This program will create an ascii file which will be downloaded
 * to floppy (initially) and then forwarded to the National Student
 * Loan Clearinghouse processing center in Herndon Virginia.
 *
 *
 **********************************************************************
C*
 * The information contained herein is proprietary to and considered a 
C*
 * trade secret of LESLEY COLLEGE and shall not be reproduced in part  
C*
 * or in whole without the written authorization of LESLEY COLLEGE.    
C*
 **********************************************************************
C*
 
      $INSERT I_COMMON FROM UT.INSERTS
      $INSERT I_GRAPHIC.CHAR FROM UT.INSERTS
      $INSERT I_SYSTEM.COMMON FROM SOURCE.INSERTS
 
      EQUATE DING TO CHAR(007)
      DAY = OCONV(DATE(),'DW')
      DOW = OCONV(DATE(),'DWA')
      CURDAY = OCONV(DATE(),'DWAMDY,A,Z4')
      DOY = DATE()
      TODAY = OCONV(DATE(),"D4")
      TEST = ""
      TERM.REC = ""
      TERM.START.DATE = ""
      TERM.END.DATE = ""
      ST.TERM.DATE = ""
      DOWNLOAD.REC = "" ; DNLD.REC = ""
      BLANK = STR(" ",20)
      TOT.REC = ""
      OUTBUF = ""
      OUTBUF = "SELECT STUDENTS WITH TERMS.RTW = '"
 
 *---- Open files not opened by I_SYSTEM.COMMON
 
      OPEN "","AR.BILLINGS" TO F.AR.BILLINGS ELSE
         CALL FATAL.ERROR("MISSING.FILE","AR.BILLINGS")
      END
      OPEN "","COURSE.SECTIONS" TO F.COURSE.SECTIONS ELSE
         CALL FATAL.ERROR("MISSING.FILE","COURSE.SECTIONS")
      END
      OPEN "","GRAD.DATE.XREF" TO F.GRAD.DATE.XREF ELSE
         CALL FATAL.ERROR("MISSING.FILE","GRAD.DATE.XREF")
      END
      OPEN "","NSLC.DATA" TO F.NSLC.DATA ELSE
         CALL FATAL.ERROR("MISSING.FILE","NSLC.DATA")
      END
      OPEN "","REG.COMMENTS" TO F.REG.COMMENTS ELSE
         CALL FATAL.ERROR("MISSING.FILE","REG.COMMENTS")
      END
      OPEN "","STUD.SCHEDS" TO F.STUD.SCHEDS ELSE
         CALL FATAL.ERROR("MISSING.FILE","STUD.SCHEDS")
      END
      OPEN "","STUDENTS" TO F.STUDENTS ELSE
         CALL FATAL.ERROR("MISSING.FILE","STUDENTS")
      END
      OPEN "","TERMS" TO F.TERMS ELSE
         CALL FATAL.ERROR("MISSING.FILE","TERMS")
      END
      OPEN "","UFD" TO F.UFD ELSE
         CALL FATAL.ERROR("MISSING.FILE","UFD")
      END
      OPEN "DICT","STUDENTS" TO F.DICT.STUDENTS ELSE
         CALL FATAL.ERROR("MISSING.FILE","DICT.STUDENTS")
      END
 
      OPEN "","SAVEDLISTS" TO F.SAVEDLISTS ELSE STOP
      SAVE.LIST = ""
 
 *---- Read idescriptor for total credits accumulated for each student
 
      TT.TOT.CREDS = ""
      READ TT.TOT.CREDS FROM F.DICT.STUDENTS, "TOT.CREDS.EARNED" ELSE
         PRINT @(0,20):DING:"TOTAL.CREDS I-DESCRIPTOR MISSING. JOB ABOR
CTED!"
         INPUT NL
         STOP
      END
 
 *---- Clear screen and display header
 
      PRINT CLEAR.SCREEN
      PRINT @(26,0):"NSLC Download Process":@(68):TODAY
 
 *---- Get TERM being processed.
 
      PRINT @(10,4):"Enter Term being processed for this download: "
      LOOP
         PRINT @(56,4):"XX/XX":CLEAR.EOL:@(56):
         INPUT P.TERM
         VALID = 1
         TERM.REC = ""
         READ TERM.REC FROM F.TERMS, P.TERM ELSE
            VALID = 0
         END
      UNTIL VALID OR P.TERM = "END"
      REPEAT
      IF P.TERM = "END" THEN
         PRINT CLEAR.SCREEN
         STOP
      END
 
      OUTBUF := P.TERM:"' BY LAST BY FIRST"
 
 *---- Get the start end dates for term for detail record
 *     and arrange in YYYYMMDD order for ascii record.
 
      F.VAL = ""
      F.VAL = OCONV(TERM.REC<5>,"D4*")
      ST.TERM.DATE = TERM.REC<5>                ;* used for comparison
      TERM.START.DATE = FIELD(F.VAL,"*",3,1)    ;* 4 digit year
      TERM.START.DATE := FIELD(F.VAL,"*",1,1)   ;* 2 digit month
      TERM.START.DATE := FIELD(F.VAL,"*",2,1)   ;* 2 digit day
 
      F.VAL = ""
      F.VAL = OCONV(TERM.REC<6>,"D4*")
      TERM.END.DATE = FIELD(F.VAL,"*",3,1)      ;* 4 digit year
      TERM.END.DATE := FIELD(F.VAL,"*",1,1)     ;* 2 digit month
      TERM.END.DATE := FIELD(F.VAL,"*",2,1)     ;* 2 digit day
 
 *---- Determine session
 
      SESSION.DESC = ""
      SESSION = P.TERM[4,2]
      BEGIN CASE
         CASE SESSION = "FA"
            SESSION.DESC = "Fall ":P.TERM[1,2]
         CASE SESSION = "SP"
            SESSION.DESC = "Spring ":P.TERM[1,2]
         CASE SESSION = "U1"
            SESSION.DESC = "Summer ":P.TERM[1,2]
      END CASE
 
 *---- Get enrollment status date from operator.
 
      PRINT @(10,6):"Enter Enrollment Status Date................: "
      LOOP
         PRINT @(56,6):"##/##/##":CLEAR.EOS:@(56):
         INPUT ENTERED.DATE
      UNTIL NUM(ICONV(ENTERED.DATE,"D2")) OR ENTERED.DATE = "END"
      REPEAT
 
      IF ENTERED.DATE = "END" THEN
         PRINT CLEAR.SCREEN
         STOP
      END
 
 *---- Rearrange the date into the format for the ascii record
 
      F.VAL = ""
      ENTERED.DATE = OCONV(ICONV(ENTERED.DATE,"D2"),"D4*")
      F.VAL = FIELD(ENTERED.DATE,"*",3,1)          ;* 4 digit year
      F.VAL := FIELD(ENTERED.DATE,"*",1,1)         ;* 2 digit month
      F.VAL := FIELD(ENTERED.DATE,"*",2,1)         ;* 2 digit day
      ENTERED.DATE = ""
      ENTERED.DATE = F.VAL
 
 *---- Report sequence for semester
 
      PRINT @(10,8):"(F)irst or (S)econd Report for Semester.....: "
      LOOP
         PRINT @(56,8):"#":CLEAR.EOS:@(56):
         INPUT REPORT.SEQ
      UNTIL REPORT.SEQ = "F" OR REPORT.SEQ = "S"
      REPEAT
 
      BEGIN CASE
         CASE REPORT.SEQ = "F"
            REPORT.SEQ = 1
         CASE REPORT.SEQ = "S"
            REPORT.SEQ = 2
      END CASE
 
 *---- Execute OUTBUF and ensure that records were selected.
 
      PRINT @(0,1):CLEAR.EOS
      EXECUTE OUTBUF
 
      IF @SYSTEM.RETURN.CODE < 1 THEN
         PRINT @(0,1):CLEAR.EOS
         PRINT @(0,10):DING:"No records were selected. Process Aborted!
C!"
         PRINT @(0,21):"Press Return [NL] to return to menu:":
         INPUT NL
         PRINT CLEAR.SCREEN
         STOP
      END
 
 *---- Set accumulators to zero
 
      HEADER = ""
      HEADER = "LAST":SPACE(16):"FIRST":SPACE(15):"PROG MAJOR     TYPE 
CDEG    CLASS    CREDS  BILLCREDS'LL'"
      PRINTER ON
      HEADING HEADER
      F.ENROLL.CNT = 0 ; H.ENROLL.CNT = 0
      L.ENROLL.CNT = 0 ; W.ENROLL.CNT = 0
      G.ENROLL.CNT = 0 ; A.ENROLL.CNT = 0
      X.ENROLL.CNT = "000000" ; D.ENROLL.CNT = 0
      REC.CNT = 2       ;* start at 2 to count header/trailer recs
      NO.ENROLL.STAT = 0
      NO.STUDENTS.REC = 0
      NO.PEOPLE.REC = 0
      NO.REG.TERM.RECS = 0
      FICE.CODE = ""
      BRANCH.CODE = ""
      REPORT.TYPE = ""
      REPORT.DATE = DATE()
      REPORT.LEVEL = ""
 
      GOSUB BUILD.HEADER.REC
 
 *---- Main processing Loop
 
      CRT @(0,1):CLEAR.EOS:@(20,10):"Processing: "
      EOS = 0
      LOOP
         READNEXT ID ELSE
            GOSUB BUILD.TRAILER.REC
            EOS = 1
         END
 
      UNTIL EOS
 
 *---- Read PEOPLE and STUDENT records for extraction of required data.
 
         PEO.REC = ""
         ON.PEOPLE = 1
         READ PEO.REC FROM F.PEOPLE, ID ELSE
            ON.PEOPLE = 0
         END
 
         IF ON.PEOPLE THEN
 
            GOSUB CLEAR.REC.FIELDS
 
 *---- Reassign STAT.DATE with the value ENTERED.DATE
 
            STAT.DATE = ENTERED.DATE
 
            STU.REC = ""
            ON.STUDENTS = 1
            READ STU.REC FROM F.STUDENTS, ID ELSE
               ON.STUDENTS = 0
            END
 
            IF ON.STUDENTS THEN
               CRT @(32,10):FMT(ID,"L#7"):
               TERM.ID = P.TERM:"*":ID
 
 *---- Extract information
 
               LAST = PEO.REC<1>
               FIRST = PEO.REC<2>
               MIDDLE = PEO.REC<3>[1,1]
               ADDR.1 = PEO.REC<5,1>
               ADDR.2 = PEO.REC<5,2>
               CITY = PEO.REC<6>
               STATE = PEO.REC<7>
               ZIP = PEO.REC<8>
               COUNTRY = PEO.REC<9>
               SSN = PEO.REC<13>
 
 *---- Extract the date of birth and arrange for ascii record
 
               F.VAL = ""
               F.VAL = OCONV(PEO.REC<21>,"D4*")
               DOB = FIELD(F.VAL,"*",3,1)             ;* 4 digit year
               DOB := FIELD(F.VAL,"*",1,1)            ;* 2 digit month
               DOB := FIELD(F.VAL,"*",2,1)            ;* 2 digit day
 
               PROGRAM = PEO.REC<25>
               MAJOR = PEO.REC<27,1>
               DEG.VAL = PEO.REC<28,1>
               DEG.DATE = PEO.REC<29,1>
               ANT.DEG.DATE = PEO.REC<103>
               SUFFIX = PEO.REC<128>
               REG.STATUS = PEO.REC<130>
               REG.TERMS = PEO.REC<131>
               REG.DATES = PEO.REC<199>
               REG.PROGRAM = PEO.REC<201>
               DECEASED = PEO.REC<209>
 
               CLASS = STU.REC<28>
 
 *---- Get the term from reg.terms that being processed
 
               REG.PROG = "" ; REG.STAT = "" ; REG.TERM = ""
               TERM.POS = 0
               LOCATE P.TERM IN REG.TERMS<1,1> SETTING TERM.POS ELSE
                  TERM.POS = 0
               END
 
               IF TERM.POS THEN
                  REG.PROG = REG.PROGRAM<1,TERM.POS>
                  REG.STAT = REG.STATUS<1,TERM.POS>
                  REG.TERM = REG.TERMS<1,TERM.POS>
               END ELSE
                  NO.REG.TERM.RECS += 1
                  GO NEXT.RECORD
               END
 
 *---- Read STUD.SCHEDS for courses and credits.
 
               READ SCHED.REC FROM F.STUD.SCHEDS, TERM.ID ELSE
                  SCHED.REC = ""
               END
               IF SCHED.REC # "" THEN
                  COURSES = SCHED.REC<1>
                  STATUS = SCHED.REC<3>
                  SEM.CREDS = SCHED.REC<15>
               END
 
 *---- Read AR.BILLINGS record field 11 for term billing credits if
 *     the major for this record is not equal to 9900.  If the major
 *     is equal to 9900, then the program will go to a subroutine and
 *     extract each course for this record and add up the billing
 *     credits from the BILL.CREDS from the COURSE.SECTIONS record.
 
               IF MAJOR = "9900" THEN
                  GOSUB COUNT.BILL.CREDITS
               END ELSE
                  READV BILL.CREDS FROM F.AR.BILLINGS, TERM.ID, 11 ELSE
                     BILL.CREDS = 0
                  END
               END            ;* major check
 
 *---- Read REG.COMMENTS
 
               REG.COM.REC = ""
               READ REG.COM.REC FROM F.REG.COMMENTS, TERM.ID ELSE
                  REG.COM.REC = ""
               END
               IF REG.COM.REC # "" THEN
                  REG.COM.CODES = REG.COM.REC<1>
                  REG.COM.DATES = REG.COM.REC<2>
               END                ;* reg.com.rec check
 
 *---- If 2nd report of semester, then read prior report enroll.status
 *     and use to compare to current enroll.status that was determine.
 
               IF REPORT.SEQ = 2 THEN
                  GOSUB READ.PRIOR.STATUS
               END
 
 *---- Determine the proper enroll.stat for each record
 
               GOSUB DETERMINE.ENROLL.STATUS
 
 *----  Determine the anticipated degree date for enroll.stat
 *      equal to F, H, or A ONLY
 
               IF ENROLL.STAT = "F" OR ENROLL.STAT = "H" OR ENROLL.STAT
C = "A" THEN
                  GOSUB DETERMINE.ANT.DEG.DATE
               END              ;* enroll.stat check
 
 *---- If enroll.stat has been set, then increment REC.CNT
 
               IF ENROLL.STAT # "" THEN REC.CNT += 1
 
 *---- Remove any hyphens from ssn
 
               CONVERT "-" TO "" IN SSN
 
 *----- Go build detail record
 
               GOSUB BUILD.DETAIL.RECORD
            END ELSE                           ;* on.students check
               NO.STUDENTS.REC += 1
            END
 
 *---- If REPORT.SEQ = 1 then write the enroll.stat to the NSLC.DATA fi
Cle
 *     so we can use it for comparison during the second process run wi
Cthin
 *     this term.
 *     If REPORT.SEQ = 2 then look for change in enroll.stat.  If there
C is
 *     a change in the status, then look at last.update.date in STUD.SC
CHEDS
 *     and use this date for the change in status date,
 
            BEGIN CASE
               CASE REPORT.SEQ = 1
                  GOSUB WRITE.STATUS
 
               CASE REPORT.SEQ = 2
                  IF PRIOR.STAT # ENROLL.STAT THEN
                     BEGIN CASE
                        CASE PRIOR.STAT = "F" AND ENROLL.STAT = "H" OR 
CENROLL.STAT = "L"
                           GOSUB GET.STATUS.CHANGE.DATE
                        CASE PRIOR.STAT = "H" AND ENROLL.STAT = "L"
                           GOSUB GET.STATUS.CHANGE.DATE
                     END CASE
                  END
            END CASE
 
         END ELSE                              ;* on.people check
            NO.PEOPLE.REC += 1
         END
 
 *----------
 NEXT.RECORD: 
 *----------
      REPEAT
 
      WRITE DOWNLOAD.REC ON F.UFD, "NSLC.REC"
 
      WRITE SAVE.LIST ON F.SAVEDLISTS, "STB000"
 
      CRT @(0,1):CLEAR.EOS
      CRT @(0,10):"F.ENROLL.CNT====> ":F.ENROLL.CNT:
      CRT @(0,11):"H.ENROLL.CNT====> ":H.ENROLL.CNT:
      CRT @(0,12):"L.ENROLL.CNT====> ":L.ENROLL.CNT:
      CRT @(0,13):"W.ENROLL.CNT====> ":W.ENROLL.CNT:
      CRT @(0,14):"G.ENROLL.CNT====> ":G.ENROLL.CNT:
      CRT @(0,15):"A.ENROLL.CNT====> ":A.ENROLL.CNT:
      CRT @(0,16):"D.ENROLL.CNT====> ":D.ENROLL.CNT:
      CRT @(0,18):"NO.STUDENTS.REC = ":NO.STUDENTS.REC:
      CRT @(0,19):"NO.PEOPLE.REC   = ":NO.PEOPLE.REC:
      CRT @(0,20):"NO.ENROLL.STAT  = ":NO.ENROLL.STAT:
      CRT @(0,21):"TOTAL RECORDS===> ":REC.CNT:
      PRINTER OFF
      PRINTER CLOSE
      STOP
 
 *---------------
 BUILD.HEADER.REC: 
 *---------------
      F.VAL = ""
      REPORT.DATE = OCONV(REPORT.DATE,"D4*")
      F.VAL = FIELD(REPORT.DATE,"*",3,1)            ;* 4 digit year
      F.VAL := FIELD(REPORT.DATE,"*",1,1)           ;* 2 digit year
      F.VAL := FIELD(REPORT.DATE,"*",2,1)           ;* 2 digit day
 
      REPORT.DATE = ""
      REPORT.DATE = F.VAL
      REPORT.LEVEL = "F"
      REPORT.TYPE = "Y"
      FICE.CODE = "002160"
      BRANCH.CODE = ""
      BRANCH.CODE = "00"
      DOWNLOAD.REC = ""
      DOWNLOAD.REC = FMT("A1","L#2")
      DOWNLOAD.REC := FMT(FICE.CODE,"L#6")         ;* fice code
      DOWNLOAD.REC := FMT(BRANCH.CODE,"L#2")       ;* branch code
      DOWNLOAD.REC := FMT(SESSION.DESC,"L#15")     ;* term description
      DOWNLOAD.REC := FMT(REPORT.TYPE,"L#1")       ;* report type
      DOWNLOAD.REC := FMT(REPORT.DATE,"L#8")       ;* file build date
      DOWNLOAD.REC := FMT(REPORT.LEVEL,"L#1")      ;* full or partial r
Cpt
      DOWNLOAD.REC := STR(" ",215)                 ;* filler (215 space
Cs)
 
      RETURN
 
 *---------------
 CLEAR.REC.FIELDS: 
 *---------------
      LAST = ""
      FIRST = ""
      MIDDLE = ""
      SSN = ""
      ENROLL.STAT = ""
      ADDR.1 = ""
      ADDR.2 = ""
      CITY = ""
      STATE = ""
      ZIP = ""
      COUNTRY = ""
      ANT.DEG.DATE = ""
      DOB = ""
      DNLD.REC = ""
      REG.STATUS = ""
      REG.DATES = ""
      REG.TERMS = ""
      REG.STAT = ""
      REG.TERM = ""
      REG.PROG = ""
      PROGRAM = ""
      TOTAL.CREDS = ""
      MAJOR = ""
      STUD.TYPE = ""
      REG.PROGRAM = ""
      SCHED.REC = ""
      COURSES = ""
      STATUS = ""
      SEM.CREDS = ""
      BILL.CREDS = ""
      DECEASED = ""
      REG.COM.CODES = ""
      REG.COM.DATES = ""
      TERM.ID = ""
      DEG.VAL = ""
      DEG.DATE = ""
      STAT.REC.DATE = ""
 
      RETURN
 
 *-----------------
 COUNT.BILL.CREDITS: 
 *-----------------
      CNT = 1
      LOOP
         COURSE = ""
         COURSE = FIELD(COURSES,@VM,CNT)
      UNTIL NOT(COL2())
         STAT = ""
         STAT = FIELD(STATUS,@VM,CNT)
         IF STAT = "A" OR STAT = "N" THEN
            B.CRED = 0
            READV B.CRED FROM F.COURSE.SECTIONS, COURSE, 24 ELSE
               B.CRED = 0
            END
            BILL.CREDS += B.CRED
         END
         CNT += 1
      REPEAT
 
      RETURN
 
 *----------------
 READ.PRIOR.STATUS: 
 *----------------
      PRIOR.STAT = ""
      PRIOR.STAT.DATE = ""
      ENROLL.REC = ""
      READ ENROLL.REC FROM F.NSLC.DATA, P.TERM:"*":ID ELSE
         ENROLL.REC = ""
      END
 
      IF ENROLL.REC # "" THEN
         PRIOR.STAT = ENROLL.REC<1>
         PRIOR.STAT.DATE = ENROLL.REC<2>
      END
 
      RETURN
 
 *----------------------
 DETERMINE.ENROLL.STATUS: 
 *----------------------
      ENROLL.STAT = ""
      STAT.DATE = ""
 
 *---- Check for deceased date enroll.stat = "D"
 
      IF DECEASED # "" THEN
         ENROLL.STAT = "D"
         STAT.DATE = OCONV(DECEASED,"D2/")
         GO STAT.SET
      END
 
 *---- Check for students conferred a degree.  enroll.stat = "G"
 
      IF DEG.VAL # "" THEN
         NEXT.REG.TERM = ""
         NEXT.REG.TERM = REG.TERMS<1,(TERM.POS+1)>
         IF NEXT.REG.TERM = "" THEN
            IF DEG.DATE # "" THEN
               GRAD.DATE = ""
               READV GRAD.DATE FROM F.GRAD.DATE.XREF, DEG.DATE, 1 ELSE
                  GRAD.DATE = STAT.DATE
               END
               IF GRAD.DATE > ST.TERM.DATE THEN
                  ENROLL.STAT = "G"
                  STAT.DATE = OCONV(GRAD.DATE,"D2/")
                  GO STAT.SET
               END             ;* comparison date check
            END                ;* deg.date check
         END                   ;* next reg.term check
      END                      ;* deg.val check
 
 *---- Check for withdrawn students enroll.stat = "W"
 *     Enroll.stat will be set to W automatically if reg.stat = "X"
 *     If reg.stat # "x" and reg.comment.code = "WD" then check
 *     the reg.date. If the reg.date le reg.comment comment.date
 *     the enroll.stat will be set to "W".
 
      W.POS = 0
      LOCATE "WD" IN REG.COM.CODES<1,1> SETTING W.POS ELSE
         LOCATE "AD" IN REG.COM.CODES<1,1> SETTING W.POS ELSE
            W.POS = 0
         END
      END
 
      IF W.POS > 0 OR REG.STAT = "X" THEN
         R.DATE = ""
         R.DATE = REG.DATES<1,TERM.POS>
         COM.DATE = ""
         COM.DATE = REG.COM.DATES<1,W.POS>
         IF REG.STAT = "X" THEN
            ENROLL.STAT = "W"
            STAT.DATE = OCONV(R.DATE,"D2/")
            GO STAT.SET
         END ELSE
            IF COM.DATE GE R.DATE THEN
               ENROLL.STAT = "W"
               STAT.DATE = OCONV(COM.DATE,"D2/")
               GO STAT.SET
            END                     ;* date checks
         END                        ;* internal reg.stat check
      END                           ;* pos check
 
 *---- Avoid reg.status of 'X'
 
      IF REG.STAT # "X" THEN
 
 *---- Start checking program codes
 *     Check for enroll.stat = 'F'
 
         BEGIN CASE
            CASE REG.PROG = "AB" OR REG.PROG = "P1" AND STUD.TYPE # "80
C"
               ENROLL.STAT = "F"
            CASE REG.PROG = "AM" OR REG.PROG = "P2" AND MAJOR # "3500"
               ENROLL.STAT = "F"
            CASE REG.PROG = "TH" OR REG.PROG = "UT" AND CLASS = "T1" OR
C CLASS = "T2" OR CLASS = "T3"
               ENROLL.STAT = "F"
            CASE REG.PROG = "GP" OR REG.PROG = "G1" AND SEM.CREDS GE "9
C00"
               ENROLL.STAT = "F"
            CASE MAJOR = "9900" AND BILL.CREDS GE "1200"
               ENROLL.STAT = "F"
            CASE REG.PROG # "" AND SEM.CREDS GE "1200"
               ENROLL.STAT = "F"
         END CASE
 
         IF ENROLL.STAT = "F" THEN
            GO STAT.SET
         END
 
 *---- If not 'F' enroll.stat then check for 'H'
 
         IF ENROLL.STAT = "" THEN
            BEGIN CASE
               CASE REG.PROG = "AB" OR REG.PROG = "P1" AND STUD.TYPE = 
C"80"
                  ENROLL.STAT = "H"
               CASE REG.PROG = "AM" OR REG.PROG = "P2" AND MAJOR = "350
C0"
                  ENROLL.STAT = "H"
               CASE REG.PROG = "TH" OR REG.PROG = "UT" AND CLASS = "T4"
                  ENROLL.STAT = "H"
               CASE REG.PROG = "GP" OR REG.PROG = "G1" AND SEM.CREDS LE
C "800"
                  ENROLL.STAT = "H"
               CASE REG.PROG = "LM" OR REG.PROG = "G3" AND MAJOR = "990
C0" AND BILL.CREDS GE "600" AND BILL.CREDS LE "1100"
                  ENROLL.STAT = "H"
               CASE REG.PROG # "" AND SEM.CREDS GE "600" AND SEM.CREDS 
CLE "1100"
                  ENROLL.STAT = "H"
            END CASE
         END
 
         IF ENROLL.STAT = "H" THEN
            GO STAT.SET
         END
 
 *---- Check for enroll.stat = 'A'
 
         LA.POS = 0
         LOCATE "LA" IN REG.COM.CODES<1,1> SETTING LA.POS ELSE
            LA.POS = 0
         END
 
         IF LA.POS > 0 THEN
            COM.DATE = ""
            COM.DATE = REG.COM.DATES<1,LA.POS>
            STAT.DATE = OCONV(COM.DATE,"D2/")
            ENROLL.STAT = "A"
            GO STAT.SET
         END
 
 *---- if enroll.stat = "" then check for L
 
         IF ENROLL.STAT = "" THEN
            IF SEM.CREDS < "600" THEN
               IF REG.PROG # "AB" AND REG.PROG # "AM" AND REG.PROG # "T
CH" AND REG.PROG # "GP" THEN
                  IF REG.PROG # "P1" AND REG.PROG # "P2" AND REG.PROG #
C "UT" THEN
                     IF REG.PROG # "LM" OR REG.PROG # "G3" AND MAJOR # 
C"9900" THEN
                        ENROLL.STAT = "L"
                     END
                  END
               END
            END
         END                 ;* check enroll.stat
 
      END                         ;* reg.stat # "X"
 
 *-------
 STAT.SET: 
 *-------
      BEGIN CASE
         CASE ENROLL.STAT = "F"
            F.ENROLL.CNT += 1
         CASE ENROLL.STAT = "H"
            H.ENROLL.CNT += 1
         CASE ENROLL.STAT = "L"
            L.ENROLL.CNT += 1
         CASE ENROLL.STAT = "W"
            W.ENROLL.CNT += 1
         CASE ENROLL.STAT = "G"
            G.ENROLL.CNT += 1
         CASE ENROLL.STAT = "A"
            A.ENROLL.CNT += 1
         CASE ENROLL.STAT = "D"
            D.ENROLL.CNT += 1
         CASE 1
            NO.ENROLL.STAT += 1
            SAVE.LIST<-1> = ID
            P.LINE = ""
            P.LINE = FMT(LAST,"L#20"):FMT(FIRST,"L#20")
            P.LINE := FMT(REG.PROG,"L#5"):FMT(MAJOR,"L#10")
            P.LINE := FMT(STUD.TYPE,"L#5"):FMT(DEG.VAL,"L#7")
            P.LINE := FMT(CLASS,"L#5"):FMT(SEM.CREDS,"R#9")
            P.LINE := "  ":FMT(BILL.CREDS,"R#9"):" "
            P.LINE := FMT(NEXT.REG.TERM,"L#7"):FMT(OCONV(R.DATE,"D2/"),
C"L#9"):FMT(OCONV(COM.DATE,"D2/"),"L#8")
            PRINT P.LINE
            P.LINE = ""
            CONVERT @VM TO " " IN REG.COM.CODES
            P.LINE = FMT(REG.COM.CODES,"L#20"):FMT(W.POS,"L#3")
            PRINT P.LINE
            PRINT
      END CASE
 
 *---- Convert the STAT.DATE into format for NSLC.REC
 
      F.VAL = ""
      STAT.DATE = OCONV(ICONV(STAT.DATE,"D2"),"D4*")
      STAT.REC.DATE = STAT.DATE
      F.VAL = FIELD(STAT.DATE,"*",3,1)           ;* 4 digit year
      F.VAL := FIELD(STAT.DATE,"*",1,1)          ;* 2 digit month
      F.VAL := FIELD(STAT.DATE,"*",2,1)          ;* 2 digit day
      STAT.DATE = ""
      STAT.DATE = F.VAL
 
      RETURN
 
 *---------------------
 DETERMINE.ANT.DEG.DATE: 
 *---------------------
      @ID = "" ; @RECORD = ""
      @ID = ID
      @RECORD = STU.REC
      TOTAL.CREDS = ITYPE(TT.TOT.CREDS)
      CUR.ACAD.YR = "" ; END.ACAD.YR = "" ; MONTH.DAY = ""
      CUR.ACAD.YR = P.TERM[1,2]
      END.ACAD.YR = CUR.ACAD.YR + 1
      MONTH.DAY = "0601"
 
      BEGIN CASE
         CASE REG.PROG = "TH" OR REG.PROG = "UT"             ;* thresho
Cld
            BEGIN CASE
               CASE CLASS = "T1"
                  END.ACAD.YR += 3
               CASE CLASS = "T2"
                  END.ACAD.YR += 2
               CASE CLASS = "T3"
                  NULL
            END CASE
 
 *---- Women's college
 
         CASE REG.PROG = "UG" OR REG.PROG = "UJ"
            BEGIN CASE
               CASE CLASS = "FR"
                  END.ACAD.YR += 4
               CASE CLASS = "SO"
                  END.ACAD.YR += 3
               CASE CLASS = "JR"
                  END.ACAD.YR += 2
               CASE CLASS = "SR" AND TT.TOT.CREDS < 128
                  END.ACAD.YR += 1
               CASE CLASS = "SR" AND TT.TOT.CREDS GE 128
                  NULL
            END CASE
 
 *---- All other schools are caught here
 
         CASE 1
            BEGIN CASE
               CASE CLASS = "01"
                  END.ACAD.YR += 5
               CASE CLASS = "02"
                  END.ACAD.YR += 4
               CASE CLASS = "03"
                  END.ACAD.YR += 3
               CASE CLASS = "04"
                  END.ACAD.YR += 2
               CASE CLASS = "06" AND MAJOR # ""
                  END.ACAD.YR += 2
               CASE CLASS = "06" AND MAJOR = ""
                  END.ACAD.YR += 1
               CASE CLASS = "07" AND MAJOR # ""
                  END.ACAD.YR += 2
               CASE CLASS = "07" AND MAJOR = ""
                  END.ACAD.YR += 1
               CASE CLASS = "08" AND MAJOR # ""
                  END.ACAD.YR += 2
               CASE CLASS = "08" AND MAJOR = ""
                  END.ACAD.YR += 1
               CASE CLASS = "09"
                  END.ACAD.YR += 5
               CASE CLASS = "UN" OR CLASS = ""
                  END.ACAD.YR += 1
 
            END CASE
 
      END CASE          ;* main case loop
 
      IF END.ACAD.YR > 99 THEN
         ANT.DEG.DATE = "20":END.ACAD.YR[2,2]:MONTH.DAY
      END ELSE
         ANT.DEG.DATE = "19":END.ACAD.YR:MONTH.DAY
      END
 
      RETURN
 
 *------------------
 BUILD.DETAIL.RECORD: 
 *------------------
      DNLD.REC = FMT("D1","L#2")              ;* record type
      DNLD.REC := FMT(SSN,"L#9")              ;* SSN
      DNLD.REC := FMT(FIRST,"L#20")           ;* FIRST
      DNLD.REC := FMT(MIDDLE,"L#1")           ;* MIDDLE INITIAL
      DNLD.REC := FMT(LAST,"L#20")            ;* last
      DNLD.REC := FMT(SUFFIX,"L#5")           ;* name suffix
      DNLD.REC := FMT(BLANK[1,9],"L#9")       ;* new ssn
      DNLD.REC := FMT(BLANK,"L#20")           ;* former name
      DNLD.REC := FMT(ENROLL.STAT,"L#1")      ;* enroll status
      DNLD.REC := FMT(STAT.DATE,"L#8")        ;* enroll status date
      DNLD.REC := FMT(ADDR.1,"L#30")          ;* address line 1
      DNLD.REC := FMT(ADDR.2,"L#30")          ;* address line 2
      DNLD.REC := FMT(CITY,"L#20")            ;* city
      DNLD.REC := FMT(STATE,"L#2")            ;* state
      DNLD.REC := FMT(ZIP,"L#9")              ;* zip code
      DNLD.REC := FMT(COUNTRY,"L#15")         ;* country
      DNLD.REC := FMT(ANT.DEG.DATE,"L#8")     ;* ant degree date
      DNLD.REC := FMT(DOB,"L#8")              ;* date of borth
      DNLD.REC := FMT(TERM.START.DATE,"L#8")
      DNLD.REC := FMT(TERM.END.DATE,"L#8")
      DNLD.REC := FMT(BLANK[1,17],"L#17")     ;* filler
 
      DOWNLOAD.REC := @FM:DNLD.REC
 
      RETURN
 
 *----------------
 BUILD.TRAILER.REC: 
 *----------------
      DOWNLOAD.REC := @FM
      DOWNLOAD.REC := FMT("T1","L#2")             ;* value for trailer
      DOWNLOAD.REC := FMT(F.ENROLL.CNT,"R#6")     ;* status = F
      DOWNLOAD.REC := FMT(H.ENROLL.CNT,"R#6")     ;* status = H
      DOWNLOAD.REC := FMT(L.ENROLL.CNT,"R#6")     ;* status = L
      DOWNLOAD.REC := FMT(W.ENROLL.CNT,"R#6")     ;* status = W
      DOWNLOAD.REC := FMT(G.ENROLL.CNT,"R#6")     ;* status = G
      DOWNLOAD.REC := FMT(A.ENROLL.CNT,"R#6")     ;* status = A
      DOWNLOAD.REC := FMT(X.ENROLL.CNT,"R#6")     ;* status = X
      DOWNLOAD.REC := FMT(D.ENROLL.CNT,"R#6")     ;* status = D
      DOWNLOAD.REC := FMT(REC.CNT,"R#6")          ;* records processed
      DOWNLOAD.REC := STR(" ",192)                ;* filler
 
 *---- Now write total record to NSLC.DATA file with key
 *     equal to:  TERM*REPORT.SEQ
 
      TOT.REC<1> = F.ENROLL.CNT
      TOT.REC<2> = H.ENROLL.CNT
      TOT.REC<3> = L.ENROLL.CNT
      TOT.REC<4> = W.ENROLL.CNT
      TOT.REC<5> = G.ENROLL.CNT
      TOT.REC<6> = A.ENROLL.CNT
      TOT.REC<7> = X.ENROLL.CNT
      TOT.REC<8> = D.ENROLL.CNT
      TOT.REC<9> = REC.CNT
 
      WRITE TOT.REC ON F.NSLC.DATA, REPORT.SEQ:"*":P.TERM
 
      RETURN
 
 *-----------
 WRITE.STATUS: 
 *-----------
      STAT.REC = ""
      STAT.REC<1> = ENROLL.STAT
      STAT.REC<2> = STAT.REC.DATE
      WRITE STAT.REC ON F.NSLC.DATA, P.TERM:"*":ID
 
      RETURN
 
 *---------------------
 GET.STATUS.CHANGE.DATE: 
 *---------------------
      UPDATE.DATE = ""
      READV UPDATE.DATE FROM F.STUD.SCHEDS, TERM.ID, 18 ELSE
         UPDATE.DATE = ""
      END
 
      RETURN
 
 
   END
 ======== END OF RECORD ===============================================
 ### END OF FILE ######################################################
