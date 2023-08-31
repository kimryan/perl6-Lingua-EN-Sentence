NAME

Lingua::EN::Sentence - Module for splitting text into sentences.

SYNOPSIS

    use Lingua::EN::Sentence;
    add_acronyms(' Lt Gen');  ## adding support for 'Lt. Gen.' 

    $text = Q[First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
    Sentence 2: Sequences like ellipsis ... are handled. Sentence 3, numbered sections such as point 1. are ok.];
    my @sentences = $text.sentences;
    for @sentences -> $sent {
        say $sent;
    }

    Output is:

    First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
    Sentence 2: Sequences like ellipsis ... are handled.
    Sentence 3, numbered sections such as point 1. are ok.


DESCRIPTION

The Lingua::EN::Sentence module contains the method sentences, which splits
text into its constituent sentences, based on regular expressions, a list
of abbreviations (built in and given) and other rules.

Certain well know exceptions, such as abbreviations like Mr., Calif. and
Ave. will cause incorrect segmentations. But many of these are already
integrated into this code and are being taken care of. Note that
abbreviations are case sensitive.

The add_acronyms method allows you to add custom abbreviations.

ALGORITHM

Before any regex processing, quotations are hidden away and inserted after
the sentences are split. That entails that no sentence splitting will be
attempted between pairs of double quotes. Common cases of full stops that
do not denote an end of sentence are also hidden. These include the dot
after abbreviations mentioned above, acronymns and ellipsis.

Basically, I use a 'brute' regular expression to split the text into
sentences. (Well, nothing is yet split - I just mark the end-of-sentence).
Then I look into a set of rules which decide when an end-of-sentence is
justified and when it's a mistake. In case of a mistake, the
end-of-sentence mark is removed. 

What are such mistakes? Cases of abbreviations, for example. I have a list
of such abbreviations (Please see `Acronym/Abbreviations list' section),
and more general rules (for example, the abbreviations 'i.e.' and 'e.g.'
need not to be in the list as a special rule takes care of all single
letter abbreviations).

FUNCTIONS

  $text.sentences

A very convenient extension to the Perl6 Str string type, the .sentences
method allows us to natively request the sentences in a string, similarly
to the Str "words" method.

The sentences method takes a Str variable containing the text as an
argument and returns an array of sentences that the text has been split
into.

Returned sentences will be trimmed (beginning and end of sentence) of
white-spaces.

Strings with no alpha-numeric characters in them, won't be returned as
sentences.

  add_acronyms( @acronyms )

This function is used for adding acronyms not supported by this code.
Please see `Acronym/Abbreviations list' section for the abbreviations
already supported by this module.

  get_acronyms()

This function will return the defined list of acronyms.

  set_acronyms( @my_acronyms )

This function replaces the predefined acroynm list with the given list.

  get_EOS()

This function returns the value of the string used to mark the end of
sentence. You might want to see what it is, and to make sure your text
doesn't contain it. You can use set_EOS() to alter the end-of-sentence
string to whatever you desire.

  set_EOS( $new_EOS_string )

This function alters the end-of-sentence string used to mark the end of
sentences.

Acronym/Abbreviations list

You can use the get_acronyms() function to get acronyms. It has become too
long to specify in the documentation.

If I come across a good general-purpose list - I'll incorporate it into
this module. Feel free to suggest such lists.

Limitations

There are some valid cases cannot be detected, such as: This belongs to
John A. Smith, which will break after A. This cannot be distinguished from
a valid sequence like so said I. Next sentence. A sentence ending in an
acronym does not cause a split such as St.

AUTHOR

Deyan Ginev, 2013. Kim Ryan, 2023

Perl5 CPAN author: Shlomo Yona (shlomo@cs.haifa.ac.il)

Released under the same terms as Perl 6; see the LICENSE file for details.
