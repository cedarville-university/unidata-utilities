##############################
## shared.ph
## 11/19/2001
## dave rotman
##
## sample Perl script to illustrate connecting to
## a Unidata host and producing Web pages
##
##############################

require("defaults.ph");

sub TopHTML {
  local($title) = @_; shift;
  ## Pass a focus with the form name and the edit name
  ## i.e. "MyForm.subject"
  local($focus) = @_;
  print "<HTML><HEAD><TITLE>$title</TITLE>\n";
  &IncludeBeforeBody5;
  print "</HEAD><BODY BGCOLOR=\"#FFFFFF\" TOPMARGIN=\"0\" LEFTMARGIN=\"0\" MARGINWIDTH=\"0\" MARGINHEIGHT=\"0\"";
  if ($focus) {
    print " onload=\"javascript:if (document.forms[0] != null) {if (document.$focus != null){document.$focus.focus();}}\"";
  }
  print ">\n";
  &IncludeAfterBody5;
}

sub PrintHeader
{
  ## Title, Focus, NoCache, Image, HeaderTitle
  local($title) = @_; shift;
  ## Pass a focus with the form name and the edit box name
  ## i.e. "MyForm.subject"
  local($focus) = @_; shift;
  local($nocache) = @_; shift;
  local($image) = @_; shift;
  local($headertitle) = @_;
  if (! $title) { $title = "CedarInfo"; }
  if (! $image) { $image = "cfcedarinfo"; }
  if ((uc $image) eq "NONE") { $image = ""; }
  if ($nocache) {
    print "Content-type: text/html\n";
    print "Pragma: no-cache\n";
    print "\n";
  } else {
    print "Content-type: text/html\n";
    print "\n";
  }
  print "<HTML><HEAD><TITLE>$title</TITLE>\n";
  &InsertHead;
  print "</HEAD><BODY BGCOLOR=\"#FFFFFF\" TOPMARGIN=\"0\" LEFTMARGIN=\"0\" MARGINWIDTH=\"0\" MARGINHEIGHT=\"0\"";
  if ($focus) {
    print " onload=\"javascript:if (document.forms[0] != null) {if (document.$focus != null){document.$focus.focus();}}\"";
  }
  print ">\n";
  if ($image) {  
    &InsertTopNavStart;
    &InsertHeaderImage("$image");
    &InsertTopNavEnd;
    &InsertMainTableStart;
  } else {
    &InsertTopNavNoHeaderImage;
  }
  if ($headertitle) { print &IncludeTitle($headertitle); }
}


sub IncludeBadCharJS {
  print <<END_OF_JS;
  <script language="javascript">
  <!--hide Javascript
  function CheckChars(item) {
    item.value = stripCharsInBag(item.value);
  }

  function stripCharsInBag(s) {
    var i;
    var returnString = "";
    var bag = ";<>*|\$\'!#()[]{}`";
    for (i = 0; i < s.length; i++)
    {
      var c = s.charAt(i);
      if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
  }
  // end of Javascript hide -->
  </script>
END_OF_JS

}


sub PrintTopOfForm
{
  local( $methodType ) = @_ ;
  print "<FORM NAME=\"MyForm\" ACTION=\"$progName\" METHOD=\"POST\">\n";
}

sub StartTable
{
  local( $borderstyle ) = $_[0];
  if ($borderstyle eq "") {
    $borderstyle = 0;
  }
  print "<TABLE BORDER=\"$borderstyle\">\n";
}

sub EndTable
{
  print "</TABLE>\n";
}

sub PrintLine
{
  local( $column1 ) = $_[0];
  local( $column2 ) = $_[1];
  print "<TR><TD>\n$column1\n</TD><TD>$column2</TD></TR>\n";
  return;
}

sub PrintTrailer
{
  if ($sid) { &PrintData($sid); }
  &InsertHead;  ## TEMPORARY UNTIL InsertHead ALWAYS HAPPENS AT TOP OF PAGE
  &InsertBottom;
  print $q->end_html.$CR;
}


sub SendRequest
{
#  $test_print should be set in the calling program
  if ($test_print) { print $q->header; }
  $q->delete('Submit Request');
  $q->delete('Continue');
  local(@names) = $q->param;
  local($sendStr) = "";
  local($realUser) = &GetRealUserID($sid);
  local($viewUser) = &GetUserID($sid);
  local($passUser) = "";
  if ($realUser eq $viewUser) {
    $passUser = $realUser;
  } else {
    $passUser = $viewUser . "~" . $realUser;
  }
                   # "\\\"".&GetUserID($sid)."\\\" ".
  foreach (@names) {
    if ($_ ne "callingSubroutine") {
      $currStr = $q->param($_);
      $currStr =~ s/\r\n/ /go;
      $sendStr = $sendStr . "\\\"".$currStr."\\\" ";
      if ($_ eq "method") {
        $sendStr = $sendStr .
                   "\\\"".$passUser."\\\" ".
                   "\\\"constantpassword\\\" ";
      }
    }
  }
  if ($test_print) { print $q->dump; }
  if ($test_print) { print $sendStr.$BR.$CR; }
  if ($sendStr =~ tr/;<>*|`$!#()[]{}'//) {
    if (! $test_print) { 
      print $q->header; 
      &TopHTML('ERROR!'); 
    }
    print "<H1>Invalid Characters Passed</H1>" ;
    print "<H3>Cannot use the following characters:\n";
    #print "<BR>$illegal_chars";
    print "&nbsp;&nbsp;<>*|`$!'#()[]{}";
    print "<BR><BR>";
    print "Please click the Back button on your browser";
    print "</H3>";
  } else {
    if (! $test_print) {
      # the _system_ call waits for the process to return; _exec_ does not
      if ($test_run) {
         $xlogin = $testuser;
      } else {
         $xlogin = $remoteuser;
      }
      system("rsh -l $xlogin 10.10.102.245 $sendStr") ;
    }
  }
  &PrintTrailer;
}


sub AuthErrorStop {
  print $q->header(-pragma=>'no-cache');
  TopHTML("$title: Invalid Security Authorization");
  print &IncludeTitle2("$title: Invalid Security Authorization")."<BR>";
  print "<BR><BR><H2>Invalid Security Authorization</H2><BR><BR>";
  &PrintTrailer;
  exit;
}

sub AuthDownStop {
  print $q->header(-pragma=>'no-cache');
  TopHTML("$title: This option is down");
  print &IncludeTitle2("$title:This option is down")."<BR>";
  print "<BR><BR><H2>This option is currently down.</H2><BR><BR>";
  &PrintTrailer;
  exit;
}

1;
