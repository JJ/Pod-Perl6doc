=begin pod

Original is https://github.com/rakudo/rakudo/blob/nom/lib/Pod/To/Text.pm

LINCENSE The Artistic License 2.0
See https://github.com/rakudo/rakudo/blob/nom/LICENSE

-----
!!!!! DO NOT USE THIS MODULE! THIS IS Pod-Perl6doc INTERNAL ONLY !!!!

Tweak
* use Terminal::ANSIColor always
* colorlize headers
* colorlize code

=end pod

unit class Pod::To::TextPodPerl6doc;
use Terminal::ANSIColor;

method render($pod) {
    pod2text($pod)
}

sub pod2text($pod) is export {
    given $pod {
        when Pod::Heading      { heading2text($pod)             }
        when Pod::Block::Code  { code2text($pod)                }
        when Pod::Block::Named { named2text($pod)               }
        when Pod::Block::Para  { twrap( $pod.contents.map({pod2text($_)}).join("") ) }
        when Pod::Block::Table { table2text($pod)               }
        when Pod::Block::Declarator { declarator2text($pod)     }
        when Pod::Item         { item2text($pod).indent(2)      }
        when Pod::FormattingCode { formatting2text($pod)        }
        when Positional        { $pod.map({pod2text($_)}).join("\n\n")}
        when Pod::Block::Comment { '' }
        when Pod::Config       { '' }
        default                { $pod.Str                       }
    }
}

sub heading2text($pod) {
    given $pod.level {
        when 1  {          colored(pod2text($pod.contents), "cyan")  }
        when 2  { '  '   ~ colored(pod2text($pod.contents), "cyan")  }
        default { '    ' ~ colored(pod2text($pod.contents), "cyan")  }
    }
}

sub code2text($pod) {
    my @lines = $pod.contents>>.&pod2text.split(/\n/);
    my Str $text;
    for @lines -> $line {
        $text ~= "    " ~ colored($line, "magenta") ~ "\n";
    }
    return $text;
}

sub item2text($pod) {
    '* ' ~ pod2text($pod.contents).chomp.chomp
}

sub named2text($pod) {
    given $pod.name {
        when 'pod'  { colored(pod2text($pod.contents), "cyan")     }
        when 'para' { colored(para2text($pod.contents[0]), "cyan") }
        when 'defn' { colored(pod2text($pod.contents[0]), "cyan") ~ "\n"
                    ~ pod2text($pod.contents[1..*-1]) }
        when 'config' { }
        when 'nested' { }
        default     { colored($pod.name, "cyan") ~ "\n" ~ pod2text($pod.contents) }
    }
}

sub para2text($pod) {
    twine2text($pod.contents)
}

sub table2text($pod) {
    my @rows = $pod.contents;
    @rows.unshift($pod.headers.item) if $pod.headers;
    my @maxes;
    for 0..(@rows[1].elems - 1) -> $i {
        @maxes.push([max] @rows.map({ $_[$i].chars }));
    }
    my $ret;
    if $pod.config<caption> {
        $ret = $pod.config<caption> ~ "\n"
    }
    for @rows -> $row {
        for 0..($row.elems - 1) -> $i {
            $ret ~= $row[$i].fmt("%-{@maxes[$i]}s") ~ "  ";
        }
        $ret ~= "\n";
    }
    return $ret;
}

sub declarator2text($pod) {
    next unless $pod.WHEREFORE.WHY;
    my $what = do given $pod.WHEREFORE {
        when Method {
            my @params=$_.signature.params[1..*];
              @params.pop if @params[*-1].name eq '%_';
            'method ' ~ $_.name ~ signature2text(@params)
        }
        when Sub {
            'sub ' ~ $_.name ~ signature2text($_.signature.params)
        }
        when .HOW ~~ Metamodel::ClassHOW {
            'class ' ~ $_.perl
        }
        when .HOW ~~ Metamodel::ModuleHOW {
            'module ' ~ $_.perl
        }
        when .HOW ~~ Metamodel::PackageHOW {
            'package ' ~ $_.perl
        }
        default {
            ''
        }
    }
    return "$what\n{$pod.WHEREFORE.WHY.contents}"
}

sub signature2text($params) {
      $params.elems ??
      "(\n\t" ~ $params.map({ $_.perl }).join(", \n\t") ~ "\n)" 
      !! "()";
}

my %formats =
  C => "bold",
  L => "underline",
  D => "underline",
  R => "inverse"
;

sub formatting2text($pod) {
    my $text = $pod.contents>>.&pod2text.join;
    if $pod.type ~~ %formats {
        return colored($text, %formats{$pod.type});
    }
    $text
}

sub twine2text($twine) {
    return '' unless $twine.elems;
    my $r = $twine[0];
    for $twine[1..*] -> $f, $s {
        $r ~= twine2text($f.contents);
        $r ~= $s;
    }
    return $r;
}

sub twrap($text is copy, :$wrap=75 ) {
    $text ~~ s:g/(. ** {$wrap} <[\s]>*)\s+/$0\n/;
    return $text
}

# vim: ft=perl6
