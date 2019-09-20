# Unidata Download Utility (and other Unidata utilities)

The programs on this repository have been contributed by the authors
for use by anyone who wants them.  All programs are strictly
AS IS...no warranty is offered.  However, most of these programs
are being used successfully at a variety of installations.


Directories at this level:


download       Create merge files, HTML files, XML files, dbf files, XLSX files,
               and ASCII files using LIST-style syntax.  Options include
               adding control breaks, heading and footing records,
               secondary file access without the use of I-descriptors 
               or virtual fields.  Reference manual included.
               Installation procedures for Unidata, Universe, and
               Prime Information.  Operating system support for
               Unix, Windows, and Primos.
               (no password required)


unidata        Various utilities designed for the Unidata environment.
               Many would also work in the Universe environment.
               (no password required)



==================================================================


Some highlights of the unidata/cedarville subdirectory:


ae             Utilities to add custom commands to the AE editor

cctemplates    Skeleton programs to form basis for new programs

print.page     Page-formatting routine which produces ASCII output
               from Unidata files.  Useful for standard layout
               documents like subscription notices, customer
               information sheets, etc.

subroutines    Various subroutines for use in virtual fields.
               These subroutines provide sorting, run-time
               prompting, handling of multi-value associations,
               etc.

utilities      Various programs for producting cross tabulations,
               and histograms, viewing records, sorting lists,
               etc.

view.spool     User oriented lp spool control and modifcation program.
               Requires adding C functions to UniData's cfuncdef and 
               remaking udt.

voc            Safe versions of CLEAR.FILE and DELETE.FILE

webinterface   Sample files showing how Cedarville University connects
               Unidata information to the Web
