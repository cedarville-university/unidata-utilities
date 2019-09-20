##############################
## example shared constants 
## Created: 26-JUN-2000 mbm
##############################


$title              = "Example";
$remoteuser = "adam";
$testuser = "eve";

# Use the next 2 variables to make the interface unavailable
$take_down          = 0; #### 0=normal mode; 1=down mode
## The takedown screen begins with: "$title is currently unavailable for use.<BR>"
$bu_descr = "It should be available by 9am EST. We apologize for the inconvenience.";

$CR = "\n";
$BR = "<br>";
$illegal_chars_raw = ';<>*|$\'!#()[]{}`&';
$mailprog = '/usr/sbin/sendmail';

$OK_CHARS           = '-a-zA-Z0-9_.@';
$PWD_OK_CHARS       = '-a-zA-Z0-9_';

1;

