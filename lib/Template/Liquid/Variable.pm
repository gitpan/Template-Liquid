package Template::Liquid::Variable;
{ $Template::Liquid::Variable::VERSION = 'v1.0.0' }
require Template::Liquid::Error;
our @ISA = qw[Template::Liquid::Document];

sub new {
    my ($class, $args) = @_;
    raise Template::Liquid::ContextError {
                                       message => 'Missing template argument',
                                       fatal   => 1
        }
        if !defined $args->{'template'}
        || !$args->{'template'}->isa('Template::Liquid');
    raise Template::Liquid::ContextError {
                                         message => 'Missing parent argument',
                                         fatal   => 1
        }
        if !defined $args->{'parent'};
    raise Template::Liquid::SyntaxError {
                   message => 'Missing variable name in ' . $args->{'markup'},
                   fatal   => 1
        }
        if !defined $args->{'variable'};
    return bless $args, $class;
}

sub render {
    my ($s) = @_;
    my $val = $s->{template}{context}->resolve($s->{'variable'});
FILTER: for my $filter (@{$s->{'filters'}}) {
        my ($name, $args) = @$filter;
        map { $_ = $s->{template}{context}->resolve($_) || $_ } @$args;
    PACKAGE: for my $package (@{$s->{template}{filters}}) {
            if (my $call = $package->can($name)) {
                $val = $call->($val, @$args);
                next FILTER;
            }
        }
        raise Template::Liquid::FilterNotFound $name;
    }
    return join '', @$val      if ref $val eq 'ARRAY';
    return join '', keys %$val if ref $val eq 'HASH';
    return $val;
}
1;

=pod

=head1 NAME

Template::Liquid::Variable - Generic Value Container

=head1 Description

This class can hold just about anything. This is the class responsible for
handling echo statements:

    Hello, {{ name }}. It's been {{ lastseen | date_relative }} since you
    logged in.

Internally, a variable is the basic container for everything; lists, scalars,
hashes, and even objects.

L<Filters|Template::Liquid::Filter> are applied to Template::Liquid::Variable during the
render stage.

=head1 Author

Sanko Robinson <sanko@cpan.org> - http://sankorobinson.com/

CPAN ID: SANKO

=head1 License and Legal

Copyright (C) 2009-2012 by Sanko Robinson E<lt>sanko@cpan.orgE<gt>

This program is free software; you can redistribute it and/or modify it under
the terms of
L<The Artistic License 2.0|http://www.perlfoundation.org/artistic_license_2_0>.
See the F<LICENSE> file included with this distribution or
L<notes on the Artistic License 2.0|http://www.perlfoundation.org/artistic_2_0_notes>
for clarification.

When separated from the distribution, all original POD documentation is
covered by the
L<Creative Commons Attribution-Share Alike 3.0 License|http://creativecommons.org/licenses/by-sa/3.0/us/legalcode>.
See the
L<clarification of the CCA-SA3.0|http://creativecommons.org/licenses/by-sa/3.0/us/>.

=cut
