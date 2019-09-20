#!/pro/bin/perl

# http://cpansearch.perl.org/src/HMBRAND/Text-CSV_XS-1.01/examples/csv2xls
# csv2xls: Convert csv to xls
#	   (m)'11 [06 Oct 2011] Copyright H.M.Brand 2007-2013

# modified 09/24/2013-11/05/2013 David Rotman, Cedarville University
#   Many of these changes are stylistic changes based on personal preferences.
#   The original script by H.M.Brand can be used without concern for accurateness
#   and functionality. 
#
#   This version of the script explicitly identifies input and output files, so this
#   version is not suitable for piping (receiving input from a previous program
#   rather than from a file) nor for processing several input files in one invocation.
#   The specification of input file and output files fits well in the Unidata/Universe
#   environment (used by the Cedarville Download utility), whereas piping is not essential.
#
# Summary of changes:
#   produce xlsx file instead of xls
#   change script name to csv2xlsx.pl
#   do not add 'xlsx' suffix to output filename if filename is specified explicitly
#   include some additional error checking
#   rename some variables ($title becomes $inputfile, $xlsx becomes $outputfile, etc.)
#   adjust status display messages based on existing verbosity option
#   make some cosmetic code changes (use explicit if statements, show more structure on setup)
#   allow specifying input and output files via command-line switches (-i and -o)

use strict;
use warnings;

#our $VERSION = "1.71"; base script from H.M.Brand
my $scriptversion = "2.01 (David Rotman, Cedarville University, 11/05/2013)";

my $separator = '';              # Set after reading first line in attempt to auto-detect
my $quotechar = '"';
my $escapechar = '"';
my $wanthelp = 0;
my $mincolumnwidth = 4;          # Default minimal column width
my $inputfile = '';	         # Input file (CSV, tab delimited, etc.)
my $outputfile = '';	         # Excel output file name
my $forcefile = 0;               # Force use of file (do not prompt prior to overwriting)
my $utf = 0;                     # Data is encoded in Unicode
my $allowformulas = 0;           # Allow formulas
my $dateformat = "dd-mm-yyyy";
my $currencyformat = '$###,###,##0.00';
my $verbosity = 1;               # range from 1 to 4
my $datecolumns;
my $remainingchar;
my $firstchar;

sub usage
{
    my $err = shift and select STDERR;
    print <<EOU;
usage: perl csv2xlsx.pl [-s <sep>] [-e <esc>] [-q <quot>] [-w <width>] [-d <dtfmt>]
                        [-F] [-f] [-D <cols>] [-u] [-v <level>]
                        [-o <outputfilename>]
                        [-i <inputfilename>]
                        [inputfilename] [outputfilename]

    -s <sep>              use <sep>   as separator character, auto-detect, default = ','
                             The string "tab" is allowed.
    -e <esc>              use <esc>   as escape character, auto-detect, default = '$escapechar'
                             The string "undef" is allowed.
    -q <quot>             use <quot>  as quotation character, default = '$quotechar'
                             The string "undef" will disable quotation.
    -w <width>            use <width> as minimum column width, default = $mincolumnwidth
    -d <dtfmt>            use <dtfmt> as date format, default = '$dateformat'

    -F                    allow formulas, otherwise fields starting with an equal sign
                             are forced to string
    -f                    force usage of <outputfilename> if it already exists (unlink before use)
    -D <cols>             only convert dates in columns <cols>, default is everywhere
    -u                    input file is stored in UTF8 character set
    -v <level>            verbosity, default = $verbosity, maximum = 4

    -i <inputfilename>    use <inputfilename> for input to the routine

    -o <outputfilename>   write output to file named <outputfilename>, defaults
                          to input file name with .csv replaced with .xlsx

Examples:
   perl csv2xlsx.pl sales.csv                       (creates sales.xlsx)
   perl csv2xlsx.pl -o report.xlsx sales.csv        (creates report.xlsx)
   perl csv2xlsx.pl -i sales.csv -o report.xlsx     (creates report.xlsx)
   perl csv2xlsx.pl sales.csv report.xlsx           (creates report.xlsx)
   perl csv2xlsx.pl -v 4 sales.csv report.xlsx      (creates report.xlsx, shows progress msgs)

EOU
    exit $err;
} # usage


use Getopt::Long qw(:config bundling nopermute passthrough);


GetOptions (
    "help|h|?"	=> \$wanthelp ,
    "s=s"	=> \$separator,
    "q=s"	=> \$quotechar,
    "e=s"	=> \$escapechar,
    "w=i"	=> \$mincolumnwidth,
    "o=s"	=> \$outputfile,
    "i=s"	=> \$inputfile,
    "d=s"	=> \$dateformat,
    "D=s"	=> \$datecolumns,
    "f"		=> \$forcefile,
    "F"		=> \$allowformulas,
    "u"		=> \$utf,
    "v:1"	=> \$verbosity,
    );

if ($wanthelp) {
  usage(1);
}

if ($verbosity > 1) {
   print STDERR  "\ncsv2xlsx.pl script version " . $scriptversion . "\n\n";
}


my $numargs = $#ARGV + 1;
if (($numargs < 1) and ($inputfile eq "")) {
  usage(1);
}
if ($inputfile eq "") {
   $inputfile = $ARGV[0];
}
if ($verbosity > 1) {
   print STDERR "Input file is    " . $inputfile . "\n";
}
if (!(-f $inputfile)) {
   print STDERR $inputfile . " does not exist.\n";
   exit 1;
}

if ($outputfile eq "") {
   if ($numargs > 1) {
      $outputfile = $ARGV[1];
   } else {
      ($outputfile ||= $inputfile) =~ s/(?:\.csv)?$/.xlsx/i;
   }
}
if ($verbosity > 1) {
  print STDERR "Output file is   " . $outputfile . "\n";
}

-s $outputfile && $forcefile and unlink $outputfile;
if (-s $outputfile) {
    print STDERR "File '$outputfile' already exists. Overwrite? [y/N] > N\b";
    scalar <STDIN> =~ m/^[yj](es|a)?$/i or exit;
    }

# Don't split ourselves when modules do it _much_ better, and follow the standards
use Text::CSV_XS;
use Date::Calc qw( Delta_Days Days_in_Month );
use Excel::Writer::XLSX;
use Encode qw( from_to );

my $csv;
my $wbk = Excel::Writer::XLSX->new ($outputfile);
my $wks = $wbk->add_worksheet ();
   $dateformat =~ s/j/y/g;

my %fmt = (
    date	=> $wbk->add_format (
	num_format	=> $dateformat,
	align		=> "center",
	),

    rest	=> $wbk->add_format (
	align		=> "left",
	),
    );

my $wbkcurrencyformat = $wbk->add_format();
$wbkcurrencyformat->set_num_format($currencyformat);

my ($numrows, $numcols, @numcols) = (0, 1); # data height, data width, and default column widths
my $row;
my $firstline = '';
open my $inputfh, $inputfile or die "unable to open " . $inputfile . "\n";
unless ($separator) { # No sep char passed, try to auto-detect;
    while (<$inputfh>) {
	m/\S/ or next;	# Skip empty leading blank lines
	$separator = # start auto-detect with quoted strings
	       m/["\d];["\d;]/  ? ";"  :
	       m/["\d],["\d,]/  ? ","  :
	       m/["\d]\t["\d,]/ ? "\t" :
	       # If neither, then for unquoted strings
	       m/\w;[\w;]/      ? ";"  :
	       m/\w,[\w,]/      ? ","  :
	       m/\w\t[\w,]/     ? "\t" :
				  ";"  ;
	    # Yeah I know it should be a ',' (hence Csv), but the majority
	    # of the csv files to be shown uses semiColon ';' instead.
	$firstline = $_;
	last;
    }
}

$csv = Text::CSV_XS-> new ({
    sep_char       => $separator eq "tab"   ? "\t"  : $separator,
    quote_char     => $quotechar eq "undef" ? undef : $quotechar,
    escape_char    => $escapechar eq "undef" ? undef : $escapechar,
    binary         => 1,
    keep_meta_info => 1,
    auto_diag      => 1,
    });
if ($firstline) {
    $csv->parse ($firstline) or die $csv->error_diag ();
    $row = [ $csv->fields ];
}
if ($verbosity > 3) {
    foreach my $k (qw( sep_char quote_char escape_char )) {
	my $c = $csv->$k () || "undef";
	$c =~ s/\t/\\t/g;
	$c =~ s/\r/\\r/g;
	$c =~ s/\n/\\n/g;
	$c =~ s/\0/\\0/g;
	$c =~ s/([\x00-\x1f\x7f-\xff])/sprintf"\\x{%02x}",ord$1/ge;
	printf STDERR "%-11s = %s\n", $k, $c;
    }
}

if (my $rows = $datecolumns) {
    $rows =~ s/-$/-999/;			# 3,6-
    $rows =~ s/-/../g;
    eval "\$datecolumns = { map { \$_ => 1 } $rows }";
}

while ($row && @$row or $row = $csv->getline ($inputfh)) {
    my @row = @$row;
    @row > $numcols and push @numcols, ($mincolumnwidth) x (($numcols = @row) - @numcols);
    foreach my $c (0 .. $#row) {
	my $val = $row[$c] || "";
	my $l = length $val;
	$l > $numcols[$c] and $numcols[$c] = $l;

	if ($utf and $csv->is_binary ($c)) {
	    from_to ($val, "utf-8", "ucs2");
	    $wks->write_unicode ($numrows, $c, $val);
	    next;
	} # utf

	if ($csv->is_quoted ($c)) {
	    if ($utf) {
		from_to ($val, "utf-8", "ucs2");
		$wks->write_unicode ($numrows, $c, $val);
	    } else {
		$wks->write_string  ($numrows, $c, $val);
            }
	    next;
	} # is_quoted

	if (!$datecolumns or $datecolumns->{$c + 1}) {
	    my @d = (0, 0, 0);	# Y, M, D
	    $val =~ m/^(\d{4})(\d{2})(\d{2})$/   and @d = ($1, $2, $3);
	    $val =~ m/^(\d{2})-(\d{2})-(\d{4})$/ and @d = ($3, $2, $1);
	    if ( $d[2] >=    1 && $d[2] <=   31 &&
		 $d[1] >=    1 && $d[1] <=   12 &&
		 $d[0] >= 1900 && $d[0] <= 2199) {
		my $dm = Days_in_Month (@d[0,1]);
		$d[2] <   1 and $d[2] = 1;
		$d[2] > $dm and $d[2] = $dm;
		my $dt = 2 + Delta_Days (1900, 1, 1, @d);
		$wks->write ($numrows, $c, $dt, $fmt{date});
		next;
            }
       } # datecolumns

       if (!$allowformulas && $val =~ m/^=/) {
	    $wks->write_string  ($numrows, $c, $val);
       } else {
            $firstchar = substr $val, 0, 1;
            #print STDERR $firstchar . "      val " . $val . "\n";
            if ($firstchar eq '$') {
               $remainingchar = substr $val, 1;
               #print STDERR "other string is " . $remainingchar . "\n";
	       $wks->write ($numrows, $c, $remainingchar, $wbkcurrencyformat);
            } else {
	       $wks->write ($numrows, $c, $val);
            }
       } # allowformulas
    } # foreach
    ++$numrows;
    if (!($numrows % 10) and ($verbosity > 2)) {
        printf STDERR "*";
        if (!($numrows % 500)) {
           printf STDERR "  processed %6d columns x %6d rows\n", $numcols, $numrows;
        }
    }
} continue { $row = undef }

if ($verbosity > 1) {
  printf STDERR "\nCreated          %s    with %6d columns %6d rows\n", $outputfile, $numcols, $numrows;
}

$wks->set_column ($_, $_, $numcols[$_]) for 0 .. $#numcols;
$wbk->close ();

