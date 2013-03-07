use v6;
#use Lingua::EN::Sentence;

# say "Initial acronyms: "~get_acronyms().perl;
# add_acronyms('some','more','entries');
# say "New acronyms: "~get_acronyms().perl;
# set_acronyms('some','more','entries');
# say "New acronyms: "~get_acronyms().perl;

my @tests = "  hi there cowboy  ", "who, me?   ", " no way.", "all ok here.","...","    ?";
token dalpha { <.alpha>|'-' }

' vice-president_is_here' ~~ /^^ <!.dalpha> dalpha+ $$/ ?? say 'YES' !! say 'NO';

say "wwooo";
