#!/usr/local/bin/perl
use CGI;
#use CGI::Carp qw(fatalsToBrowser);
$q = new CGI;

push(@INC,"/usr/local/etc/httpd/cgi-bin");
require("cc-cgi-lib.pl");
require("session.ph");
require("shared.ph");

#############################################################
# Program Name    : testtransaction
# Author          : Brad Voumard
# Creation Date   : 07 Dec 1999
# Modififications :
#      12 Jan 2000 dlr Move shared subroutines to 'shared.ph'
#############################################################

$progName = $cgi_path."testtransaction";

if ($q->param('method')) {
    $test_print = 0;
    &SendRequest;
} else {
    &getcustomerid
}

sub getcustomerid{

  # print $q->header(-pragma=>'no-cache');
  print $q->header();
  print "<HTML><HEAD><TITLE>$title: Customer Lookup</TITLE>\n";
  print "</HEAD><BODY BGCOLOR=\"#FFFFFF\" ";
  print "onload=\"javascript:if (document.MyForm != null){document.MyForm.getcustomerid.focus;}\">\n";
  print "<FONT SIZE=5><FONT SIZE=6>U</FONT>se this form to lookup customer information.";
  print "</FONT><BR>".$CR;
  print "<HR>";
  &PrintTopOfForm(CUSTOMER.LOOKUP);
  print $q->hidden('scriptname','dummy').$CR;
  print $q->hidden('method','CUSTOMER.LOOKUP').$CR;
  print "<INPUT TYPE=\"TEXT\" NAME=\"customerid\">".$CR;
  print "<BR><BR>".$CR;
  print $q->submit('Submit').$CR;
  print $q->endform.$CR;
  &PrintTrailer;
}

1;

