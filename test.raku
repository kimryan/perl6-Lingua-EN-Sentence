use lib 'lib';
use Lingua::EN::Sentence;



my Str $text = Q
[A sentence usually ends with a dot, exclamation or question mark optionally followed by a space!
A string followed by 2 carriage returns denotes a sentence, even though it doesn't end in a dot
 
Dots after single letters such as U.S.A. or in numbers like -12.34 will not cause a split
as well as common abbreviations U.K. such as Mr. J. Smith, 2 Jones St.   Ariz.   XYZ Pty. Ltd. and more.
Sequences like ellipsis ... OR . . will not casue a split.
A sentence ending in an acronym does not cause a split such as St. There are 
"Some valid cases cannot be detected", such as so said I. This cannot easily be separated
 from a valid single letter-dot sequence like the initial for a person's given name.
Numbered sections such as point 1. within a sentence will not cause a split.
See the code for all the rules that apply. This text string has 8 sentences.];


$text = Q[First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... OR . . are handled. Sentence 3, numbered sections such as point 1. are ok.];

my @sentences = $text.sentences;
for @sentences -> $sub-element {
    say $sub-element;
}


add_acronyms('Slr QED');
$text = 'fsff Slr. fff QED. fff';
@sentences = $text.sentences;
# @sentences.say;

