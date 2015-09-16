use v6;
unit class Pod::Perl6doc;

=begin pod

=head1 NAME

Pod::Perl6doc - perldoc for Perl6

=head1 SYNOPSIS

  > perl6doc File::Find

  NAME

  File::Find - Get a lazy list of a directory tree

  SYNOPSIS
    use File::Find;
    my @list := find(dir => 'foo');
    say @list[0..3];
  ...

=head1 DESCRIPTION

Pod::Perl6doc is perldoc for Perl6.

=head1 SEE ALSO

Perl5 perldoc: L<https://metacpan.org/release/Pod-Perldoc>

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Shoichi Kaji <skaji@cpan.org>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
