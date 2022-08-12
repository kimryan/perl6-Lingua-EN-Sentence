my $DOT = 'DOT';
my @TITLE = <Mr Mrs Ms Dr Prof Mme Mgr Msgr>;
# my $s = 'such as Mr. J. First 12 Smith St. ar Dr. X. Wye, 12 zedd Rd. Ariz. XYZ Pty. k Ltd.  second    Ariz.    Mr. A. Second';
my $s = 'such as A.B. and U.S.A. fkf C.S.I.R. fff.';

$s ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT$2$DOT$3$DOT /;
$s ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT$2$DOT /;
$s ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT /;


say $s;
exit;


my @ABBREVS  = < Mr Mrs Ms Dr Inc Pty Ltd Rd St Ariz >;


$s = 'dfjjdd   12. point ddd';
$s ~~ s:g/(<space>)(<digit>+)'.'(<space><lower>)/$0$1$DOT$2/;
$s ~~ s:g/j/k/;
say $s;

#$s ~~ s:g/
#(
#@TITLE
#'.'?
#<space>
#)
#(<upper>)'.'  # initial with dot
#(
#<space>
#<upper>  # surname
#<alpha>**{2..12}
#)
#/$0$1__DOT__$2/;
#say $s;
#
#for @ABBREVS -> $abbrev {
#  say $abbrev;
#  $s ~~ s:g/
#  (<space>)($abbrev)'.'(<space>)
#  /$0$1__DOT__$2/;
# 
#}
#say $s;
#
#
##$s ~~ s:g/
##<space>(@ABBREVS)'.'<space> 
##/ $0__DOT__ /;
# 
#
#
##$s ~~ s:g/
##<space>(@ABBREVS)'.'<space> 
##/ $0__DOT__ /;
##say $s;
#


