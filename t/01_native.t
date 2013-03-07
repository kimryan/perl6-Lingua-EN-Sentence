use v6;
use Lingua::EN::Sentence;

# say "Initial acronyms: "~get_acronyms().perl;
# add_acronyms('some','more','entries');
# say "New acronyms: "~get_acronyms().perl;
# set_acronyms('some','more','entries');
# say "New acronyms: "~get_acronyms().perl;

 my $text = slurp 't/tom_sawyer.txt';
 my @sentences = get_sentences($text);
 my $fh = open 't/tom_sawyer_sentences.txt', :w;
 $fh.say( @sentences.join("\n-----\n") );
$fh.close();