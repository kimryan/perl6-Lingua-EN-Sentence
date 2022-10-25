use v6;
use Lingua::EN::Sentence;

sub MAIN(Str $in_file_name, Str $out_file_name) {
    my $text = slurp $in_file_name;
    my @sentences = $text.sentences;
    my $fh = open $in_file_name, :w;
    $fh.print(@sentences.join("\n-----\n"));
    $fh.close;
}
