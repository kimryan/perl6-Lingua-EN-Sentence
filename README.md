Lingua::EN::Sentence - Module for splitting text into sentences.

SYNOPSIS
```raku
use Lingua::EN::Sentence;
add_acronyms('lt','gen');  ## adding support for 'Lt. Gen.'
 
$text = Q[First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... OR . . are handled. Sentence 3, numbered sections such as point 1. are ok.];
my @sentences = $text.sentences;
for @sentences -> $sub-element {
    say $sub-element;
}
#`[
Output is:
First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... OR . . are handled.
Sentence 3, numbered sections such as point 1. are ok.
]
```

DESCRIPTION

The Lingua::EN::Sentence module contains the method get_sentences, which
splits text into its constituent sentences, based on  regular expressions,
a list of abbreviations (built in and given) and other rules.

Certain well know exceptions, such as abreviations like Mr., Calif. and Ave. will
cause incorrect segmentations. But many of these are already integrated into this
code and are being taken care of. Still, if you see that there are words causing
the get_sentences() to fail, you can add those to the module, so it notices them.
