Lingua::EN::Sentence - Module for splitting text into sentences.

SYNOPSIS
```raku
use Lingua::EN::Sentence;
add_acronyms('lt','gen');  ## adding support for 'Lt. Gen.'
 
$text =
Q[First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... are handled. Sentence 3, numbered sections such as point 1. are ok.];
my @sentences = $text.sentences;
for @sentences -> $sub-element {
    say $sub-element;
}
#`[
Output is:
First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ...  are handled.
Sentence 3, numbered sections such as point 1. are ok.
]
```

DESCRIPTION

The Lingua::EN::Sentence module contains the method sentences, which
splits text into its constituent sentences, based on  regular expressions,
a list of abbreviations (built in and given) and other rules.

Certain well know exceptions, such as abbreviations like Mr., Calif. and Ave. will
cause incorrect segmentations. But many of these are already integrated into this
code and are being taken care of. Note that abbreviations are case sensitive.

The add_acronyms method alows you to add custom abbreviations.
