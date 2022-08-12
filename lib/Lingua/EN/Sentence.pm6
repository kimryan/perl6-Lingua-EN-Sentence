use v6;

unit module Lingua::EN::Sentence:auth<LlamaRider>;
my $VERBOSE = 0;
my Str $EOS = "__EOS__";
my Str $ELLIPSIS = "__ELLIPSIS__";
my Str $TWO_DOTS = "__TWO_DOTS__";
my Str $DOT = "__DOT__";

my token termpunct { <[.?!]> }
my token AP { [<['"»)\]}]>]? } ## AFTER PUNCTUATION
my token PAP { <termpunct> <AP> };
my token alphad { <.alpha>|'-' }


# NOTE: all abbreviations are case senstitive, specify lower case first letter only when needed
my @PEOPLE = <Mr Mrs Ms Dr Prof Mme Mgr Msgr Sen Sens Rep Reps Gov Atty Artts Supt Insp Const Det Rev Revd Ald Rt Hon>;
my @TITLE_SUFFIXES = <PhD Jr Jnr Sn Snr Esq MD LLB>;
my @ARMY = <Col Gen Lt Cm?dr Adm Capt Sgt Cpl Maj Pte>;
my @INSTITUTES = <Dept Univ Assn Bros>;
my @COMPANIES = <Inc Pty Ltd Co Corp>;
my @PLACES = <Arc Al Ave Blv Blvd Cl Ct Cres Dr Exp Expy Fwy Fy Hwy Hway La Pd Pde Pl Plz Rd St Tce
 dist mt ft 
 Ala Ariz Ark Cal Calif Col Colo Conn 
 Del Fed Fla Ga Ida Id Ill Ind Ia Kan Kans Ken Ky La Md Is Mass 
 Mich Minn Miss Mo Mont Neb Nebr Nev Mex Okla Ok Ore Penna Penn Pa 
 Dak Tenn Tex Ut Vt Va Wash Wis Wisc Wy Wyo USAFA 
 Alta Man Ont Qué Sask Yuk 
 Aust Vic Qld Tas>; # Me conflicts with me
 
my @MATH = <Fig fig eq sec i'.'e e'.'g P'-'a'.'s cf Thm Def Conj resp>;
my @MONTHS = <Jan Feb Mar Apr May Jun Jul Aug Sep Sept Oct Nov Dec >;
my @MISC = <vs no esp>; # etc causes more problems than it solves

my  Str @ABBREVIATIONS = (@PEOPLE, @TITLE_SUFFIXES, @ARMY, @INSTITUTES, @COMPANIES, @PLACES, @MONTHS, @MATH, @MISC).flat;

sub add_acronyms(*@new_acronyms) is export {
  @ABBREVIATIONS.append: @new_acronyms;
 }
sub get_acronyms() is export {return @ABBREVIATIONS;}
sub set_acronyms(*@new_acronyms) is export {
  @ABBREVIATIONS=@new_acronyms;
}
sub get_EOS() is export {return $EOS;}
sub set_EOS(Str $end_marker) is export {$EOS=$end_marker;}

#------------------------------------------------------------------------------
#`[
get_sentences - takes text input and splits it into sentences.
Firstly, letters and full stops sequences that don't end a sentence
are tranformed into another symbol.
A regular expression  cuts the text into sentences, and then a list
of rules is applied on the marked text in order to fix end-of-sentence
markings in places which are not indeed end-of-sentence.
]

sub get_sentences(Str $text) is export {
  my @sentences;
  if ($text.defined) {
    my $marked_text = mark_up_false_stops($text);
    $VERBOSE and say "MARKED UP SENTENCES\n",$marked_text;
    
    my ($quoteless_text, Array[Str] $quotes) = hide_quotes($marked_text);
    # $VERBOSE and say "QUOTELESS TEXT\n",$quoteless_text;
    my $final_text = first_sentence_breaking($quoteless_text);
    $VERBOSE and say "FINAL TEXT\n",$final_text;
    my $fixed_text = remove_false_end_of_sentence($final_text);
    $VERBOSE and say "FIXED TEXT\n", $fixed_text;
    my $quoteful_text = show_quotes($fixed_text, $quotes);
    @sentences = clean_sentences(split(/$EOS/,$quoteful_text));
   
    remove_markup(@sentences);
    
  }
  return @sentences;
}

#------------------------------------------------------------------------------
# augmenting the default Str class with a .sentences methods, 
# for extra convenience. Sweet!
#------------------------------------------------------------------------------
use MONKEY-TYPING;
use MONKEY-SEE-NO-EVAL;
augment class Str { method sentences { return get_sentences(self); } }

#==============================================================================
#
# Private methods
#
#==============================================================================

sub mark_up_false_stops(Str $request) {
  my $text = $request;
  $text ~~ s:g/'. .'/$TWO_DOTS/;
  $text ~~ s:g/'...'/$ELLIPSIS/;
  
  # mark integers ending with a . followed by space and lowercase letter such a 'point 12. states...'
  $text ~~ s:g/(<space>)(<digit>+)'.'(<space><lower>)/$0$1$DOT$2/;
  
  # Mark up acromyms
  $text ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT$2$DOT$3$DOT /; # A.B.C.D.
  $text ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT$2$DOT /; # such as U.S.A.
  $text ~~ s:g/<space>(<alpha>)'.'(<alpha>)'.'<space>/ $0$DOT$1$DOT /; # such as U.K. Also handles 2 initials in a persons name
  
  # First mark dots belonging to a persons' initials such as Mr A. Smith
  my @TITLE = <Mr Mrs Ms Dr Prof Mme Mgr Msgr>;  
  $text ~~ s:g/
  (
  @TITLE
  '.'?
  <space>
  )
  (<upper>)'.'  # initial with dot
  (
  <space>
  <upper>  # surname
  <alpha>**{2..12}
  )
  /$0$1$DOT$2/;
  
  # Now convert dot in any abbreivations including titles such as Mr. Pty. Ariz.  etc  
  for @ABBREVIATIONS -> $abbrev {
    $text ~~ s:g/
    (<space>)($abbrev)'.'(<space>)
    /$0$1$DOT$2/;
  }   
   
  return $text;
}

sub hide_quotes(Str $request) {
  my $text = $request;
  my Str @quotes;
  while ($text ~~ s/('"' <-["]>+ '"')/XXXQUOTELESSXXX/) {
    @quotes.push($0.Str);
  }
  return ($text,@quotes);
}


sub first_sentence_breaking(Str $request) {
  my $text = $request;
  $text ~~ s:g/\n<.space>*\n/$EOS/;
  $text ~~ s:g/(<&PAP><.space>)/$0$EOS/;
  $text ~~ s:g/(<.space><.alpha><&termpunct>)/$0$EOS/; # break also when single letter comes before punc.
  $text ~~ s:g/(<.alpha><.space><&termpunct>)/$0$EOS/; # Typos such as " arrived .Then "
  return $text;
}

sub remove_false_end_of_sentence(Str $request) {
  my $s = $request;
  
  # don't split after a white-space followed by a single letter followed
  # by a dot followed by another white space
  $s ~~ s:g/(<.space><.alpha>'.'<.space>+)$EOS/$0/;

  ## fix "." "?" "!"
  # TO DO, still needed with hidequotes??
  $s ~~ s:g/(<['"]><&termpunct><['"]><.space>)$EOS/$0/;
  ## don't break after quote unless its a capital letter.
  ## TODO: Need to work on balanced quotes, currently they fail.
  $s ~~ s:g/(<["']><.space>*)$EOS(<.space>*<.lower>)/$0$1/;

  return $s;
}

sub mark_splits(Str $request) {
  my $text = $request;
  $text ~~ s:g/(\D\d+)<termpunct>(<.space>+)/$0$<termpunct>$EOS$1/;
  $text ~~ s:g/(<.PAP><.space>)(<.space>*\()/$0$EOS$1/;
  $text ~~ s:g/(<[']><.alpha><.termpunct>)<space>/$0$EOS$<space>/;
  $text ~~ s:g:i/(<.space>'no.')(<.space>+)<!before \d>/$0$EOS$1/;
  
  # Split where single capital letter followed by dot makes sense to break.
  # notice these are exceptions to the general rule NOT to split on single
  # letter.
  # Notice also that single letter M is missing here due to French 'mister'
  # which is representes as M.
  #
  # the rule will not split on names beginning or containing 
  # single capital letter dot in the first or second name
  # assuming 2 or three word name.
  # Not working, is it still needed?
  # $text ~~ s/(<.space><lower><.alpha>+<.space>+<-[<upper>M]>'.')(?!<.space>+<upper>'.')/$1$EOS/sg;

 # Add EOS when you see "a.m." or "p.m." followed by a capital letter.
 $text ~~ s:g/(<[ap]>'.m.'<.space>+)<upper>/$0$EOS$<upper>/;
  return $text;
}

sub remove_markup(@sentences) {
  for @sentences <-> $sentence {
    $sentence ~~ s:g/$ELLIPSIS/.../;
    $sentence ~~ s:g/$TWO_DOTS/. ./;
    $sentence ~~ s:g/$DOT/./; 
  }
}


sub clean_sentences(@sentences) {
  return @sentences.grep({.defined and .match(/<.alpha>/)}).map:{.trim };
}



sub show_quotes(Str $request, Str @quotes) {
  my $text = $request;
  if (@quotes.elems > 0) {
    my $quote = @quotes.shift;
    while ($text ~~ s/'XXXQUOTELESSXXX'/$quote/) {
      $quote = @quotes.shift;
    }
  }
  return $text;
}

=begin pod

=head1 NAME

Lingua::EN::Sentence - Module for splitting text into sentences.

=head1 SYNOPSIS

	use Lingua::EN::Sentence;
	add_acronyms('lt','gen');  ## adding support for 'Lt. Gen.'
 
 $text = Q[First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... OR . . are handled. Sentence 3, numbered sections such as point 1. are ok.];
my @sentences = $text.sentences;
for @sentences -> $sub-element {
    say $sub-element;
}
Output is:
First sentence with some abbreviations,  Mr. J. Smith, 2 Jones St. SomeTown Ariz. U.S.A. is an address.
Sentence 2: Sequences like ellipsis ... OR . . are handled.
Sentence 3, numbered sections such as point 1. are ok.

=head1 DESCRIPTION

The C<Lingua::EN::Sentence> module contains the method get_sentences, which
splits text into its constituent sentences, based on  regular expressions,
a list of abbreviations (built in and given) and other rules.

Certain well know exceptions, such as abreviations like Mr., Calif. and Ave. will
cause incorrect segmentations. But many of these are already integrated into this
code and are being taken care of. Still, if you see that there are words causing
the get_sentences() to fail, you can add those to the module, so it notices them.

=head1 ALGORITHM

Before any regex processing, quotations are hidden away and inserted after the
sentences are split. That entails that no sentence splitting will be attempted
between pairs of double quotes. Common cases of full stops that do not denote an
end of sentence are also hidden. These include the dot after abbreviations mentioned
above and  ellipsis.

Basically, I use a 'brute' regular expression to split the text into sentences.
(Well, nothing is yet split - I just mark the end-of-sentence).  Then I look
into a set of rules which decide when an end-of-sentence is justified and when
it's a mistake. In case of a mistake, the end-of-sentence mark is removed. 

What are such mistakes? Cases of abbreviations, for example. I have a list of
such abbreviations (Please see `Acronym/Abbreviations list' section), and more
general rules (for example, the abbreviations 'i.e.' and 'e.g.' need not to be
in the list as a special rule takes care of all single letter abbreviations).

=head1 FUNCTIONS

=head2 $text.sentences

A very convenient extension to the Perl6 Str string type,  the .sentences
method allows to natively request the sentences in a string, similarly
to the Str "words" method.

This is the recommended method when writing Perl6.

=head2 get_sentences( Str $text )

The get sentences function takes a Str variable containing the text
as an argument and returns an array of sentences that the text has been
split into.

Returned sentences will be trimmed (beginning and end of sentence) of
white-spaces.

Strings with no alpha-numeric characters in them, won't be returned as sentences.

=head2 add_acronyms( @acronyms )

This function is used for adding acronyms not supported by this code.
Please see `Acronym/Abbreviations list' section for the abbreviations 
already supported by this module.

=head2 get_acronyms()

This function will return the defined list of acronyms.

=head2 set_acronyms( @my_acronyms )

This function replaces the predefined acroym list with the given list.

=head2 get_EOS()

This function returns the value of the string used to mark the end of sentence.
You might want to see what it is, and to make sure your text doesn't contain it.
You can use set_EOS() to alter the end-of-sentence string to whatever you desire.

=head2 set_EOS( $new_EOS_string )

This function alters the end-of-sentence string used to mark the end of sentences.

=head1 Acronym/Abbreviations list

You can use the get_acronyms() function to get acronyms.
It has become too long to specify in the documentation.

If I come across a good general-purpose list - I'll incorporate it into this module.
Feel free to suggest such lists.

=head1 Limitations
There are some valid cases cannot be detected, such as:
This belongs to John A. Smith, which will break after A.
This cannot  be distinguished from a valid sequence like so said I. Next sentence.
A sentence ending in an acronym does not cause a split such as St.

=head1 FUTURE WORK

[1] Code optimization. Currently everything is RE based and not so optimized RE
[2] Possibly use more semantic heuristics for detecting a beginning of a sentence
[3] "is rw" text variables. Right now the text gets copied several times which is unnecessary overhead.

=head1 SEE ALSO

	Text::Sentence

=head1 AUTHOR

Deyan Ginev, 2013.

Perl5 CPAN author:
 Shlomo Yona (shlomo@cs.haifa.ac.il)

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod
