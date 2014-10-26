package Template::Liquid::Tag;
{ $Template::Liquid::Tag::VERSION = 'v1.0.0' }
our @ISA     = qw[Template::Liquid::Document];
sub tag             { return $_[0]->{'tag_name'}; }
sub end_tag         { return $_[0]->{'end_tag'} || undef; }
sub conditional_tag { return $_[0]->{'conditional_tag'} || undef; }

# Should be overridden by child classes
sub new {
    return Template::Liquid::StandardError->new(
                                   'Please define a constructor in ' . $_[0]);
}

sub push_block {
    return Template::Liquid::StandardError->(
                'Please define a push_block method (for conditional tags) in '
                    . $_[0]);
}
1;

=pod

=head1 NAME

Template::Liquid::Tag - Documentation for Template::Liquid's Standard Tagsets

=head1 Description

Tags are used for the logic in your L<template|Template::Liquid>. New tags
are very easy to code, so I hope to get many contributions to the standard tag
library after releasing this code.

=head1 Standard Tagset

Expanding the list of supported tags is easy but here's the current standard
set:

=head2 C<comment>

Comment tags are simple blocks that do nothing during the
L<render|Template::Liquid/"render"> stage. Use these to temporarily disable
blocks of code or do insert documentation into your source code.

    This is a {% comment %} secret {% endcomment %}line of text.

For more, see L<Template::Liquid::Tag::Comment|Template::Liquid::Tag::Comment>.

=head2 C<raw>

Raw temporarily disables tag processing. This is useful for generating content
(eg, Mustache, Handlebars) which uses conflicting syntax.

    {% raw %}
        In Handlebars, {{ this }} will be HTML-escaped, but {{{ that }}} will not.
    {% endraw %}

For more, see L<Template::Liquid::Tag::Raw|Template::Liquid::Tag::Raw>.

=head2 C<if> / C<elseif> / C<else>

    {% if post.body contains search_string %}
        <div class="post result" id="p-{{post.id}}">
            <p class="title">{{ post.title }}</p>
            ...
        </div>
    {% endunless %}

=head2 C<unless> / C<elseif> / C<else>

This is sorta the opposite of C<if>.

    {% unless some.value == 3 %}
        Well, the value sure ain't three.
    {% elseif some.value > 1 %}
        It's greater than one.
    {% else %}
       Well, is greater than one but not equal to three.
       Psst! It's {{some.value}}.
    {% endunless %}

For more, see L<Template::Liquid::Tag::Unless|Template::Liquid::Tag::Unless>.

=head2 C<case>

If you need more conditions, you can use the case statement:

    {% case condition %}
        {% when 1 %}
            hit 1
        {% when 2 or 3 %}
            hit 2 or 3
        {% else %}
            ... else ...
    {% endcase %}

For more, see L<Template::Liquid::Tag::Case|Template::Liquid::Tag::Case>.

=head2 C<cycle>

Often you have to alternate between different colors or similar tasks. Liquid
has built-in support for such operations, using the cycle tag.

    {% cycle 'one', 'two', 'three' %}
    {% cycle 'one', 'two', 'three' %}
    {% cycle 'one', 'two', 'three' %}
    {% cycle 'one', 'two', 'three' %}

...will result in...

    one
    two
    three
    one

If no name is supplied for the cycle group, then it's assumed that multiple
calls with the same parameters are one group.

If you want to have total control over cycle groups, you can optionally
specify the name of the group. This can even be a variable.

    {% cycle 'group 1': 'one', 'two', 'three' %}
    {% cycle 'group 1': 'one', 'two', 'three' %}
    {% cycle 'group 2': 'one', 'two', 'three' %}
    {% cycle 'group 2': 'one', 'two', 'three' %}

...will result in...

    one
    two
    one
    two

For more, see L<Template::Liquid::Tag::Cycle|Template::Liquid::Tag::Cycle>.

=head2 C<for>

Liquid allows for loops over collections:

    {% for item in array %}
        {{ item }}
    {% endfor %}

During every for loop, the following helper variables are available for extra
styling needs:

=over

=item C<forloop.length> - length of the entire for loop

=item C<forloop.index> - index of the current iteration

=item C<forloop.index0> - index of the current iteration (zero based)

=item C<forloop.rindex> - how many items are still left?

=item C<forloop.rindex0> - how many items are still left? (zero based)

=item C<forloop.first> - is this the first iteration?

=item C<forloop.last> - is this the last iteration?

=back

There are several attributes you can use to influence which items you receive
in your loop

C<limit:int> lets you restrict how many items you get. C<offset:int> lets you
start the collection with the nth item.

    # array = [1,2,3,4,5,6]
    {% for item in array limit:2 offset:2 %}
        {{ item }}
    {% endfor %}
    # results in 3,4

For more, see L<Template::Liquid::Tag::For|Template::Liquid::Tag::For>.

=head3 Reversing the loop

To iterate in reverse use the obviously named C<reverse> keyword:

    {% for item in collection reversed %} {{item}} {% endfor %}

=head3 Custom, Dynamic Range Options

Instead of looping over an existing collection, you can define a range of
numbers to loop through. The range can be defined by both literal and variable
numbers:

    # if item.quantity is 4...
    {% for i in (1..item.quantity) %}
        {{ i }}
    {% endfor %}
    # results in 1,2,3,4

=head3 C<break>

You can use the C<{% break %}> tag to break out of the enclosing
L<<C<{% for .. %}> |Template::Liquid::Tag::For>> block. Every for block is
implicitly ended with a break.

    # if array is [[1, 2], [3, 4], [5, 6]]
    {% for item in array %}{% for i in item %}{% if i == 1 %}{% break %}{% endif %}{{ i }}{% endfor %}{% endfor %}
    # results in 3456

For more, see L<Template::Liquid::Tag::Break|Template::Liquid::Tag::Break>.

=head3 C<continue>

You can use the C<{% continue %}> tag to fall through the current iteration
of the enclosing L<<C<{% for .. %}> |Template::Liquid::Tag::For>> block.

    # if array is {items => [1, 2, 3, 4, 5]}
    {% for i in array.items %}{% if i == 3 %}{% continue %}{% else %}{{ i }}{% endif %}{% endfor %}
    # results in 1245

For more, see L<Template::Liquid::Tag::Continue|Template::Liquid::Tag::Continue>.

=head2 C<assign>

You can store data in your own variables, to be used in output or other tags
as desired. The simplest way to create a variable is with the assign tag,
which has a pretty straightforward syntax:

    {% assign name = 'freestyle' %}

    {% for t in collections.tags %}{% if t == name %}
        <p>Freestyle!</p>
    {% endif %}{% endfor %}

Another way of doing this would be to assign true / false values to the
variable:

    {% assign freestyle = false %}

    {% for t in collections.tags %}{% if t == 'freestyle' %}
        {% assign freestyle = true %}
    {% endif %}{% endfor %}

    {% if freestyle %}
        <p>Freestyle!</p>
    {% endif %}

If you want to combine a number of strings into a single string and save it to
a variable, you can do that with the capture tag.

For more, see L<Template::Liquid::Tag::Assign|Template::Liquid::Tag::Assign>.

=head2 C<capture>

This tag is a block which "captures" whatever is rendered inside it, then
assigns the captured value to the given variable instead of rendering it to
the screen.

    {% capture attribute_name %}{{ item.title | handleize }}-{{ i }}-color{% endcapture %}

    <label for="{{ attribute_name }}">Color:</label>
    <select name="attributes[{{ attribute_name }}]" id="{{ attribute_name }}">
        <option value="red">Red</option>
        <option value="green">Green</option>
        <option value="blue">Blue</option>
    </select>

For more, see L<Template::Liquid::Tag::Capture|Template::Liquid::Tag::Capture>.

=head1 Extending Solution with Custom Tags

To create a new tag, simply inherit from L<Template::Liquid::Tag|Template::Liquid::Tag>
and register your block L<globally|Template::Liquid/"Template::Liquid->register_tag( ... )">
or locally with L<Template::Liquid|Template::Liquid/"register_tag">.

For a complete example of this, see
L<Template::Solution::Tag::Include|Template::Solution::Tag::Include>.

Your constructor should expect the following arguments:

=over 4

=item C<$class>

...you know what to do with this.

=item C<$args>

This is a hash ref which contains these values (at least)

=over 4

=item C<attrs>

The attributes within the tag. For example, given C<{% for x in (1..10)%}>,
you would find C<x in (1..10)> in the C<attrs> value.

=item C<parent>

The direct parent of this new node.

=item C<markup>

The tag as it appears in the template. For example, given
C<{% for x in (1..10)%}>, the full C<markup> would be
C<{% for x in (1..10)%}>.

=item C<tag_name>

The name of the current tag. For example, given C<{% for x in (1..10)%}>, the
C<tag_name> would be C<for>.

=item C<template>

A quick link back to the top level template object.

=back

=back

Your object should at least contain the C<parent> and C<template> values
handed to you in C<$args>. For completeness, you should also include a C<name>
(defined any way you want) and the C<$markup> and C<tag_name> from the
C<$args> variable.

Enough jibba jabba... here's some functioning code...

    package Template::Solution::Tag::Random;
    our @ISA = qw[Template::Liquid::Tag];
    sub import { Template::Liquid::register_tag('random', __PACKAGE__) }

    sub new {
        my ($class, $args) = @_;
        $args->{'attrs'} ||= 50;
        my $s = bless {
                          max      => $args->{'attrs'},
                          name     => 'rand-' . $args->{'attrs'},
                          tag_name => $args->{'tag_name'},
                          parent   => $args->{'parent'},
                          template => $args->{'template'},
                          markup   => $args->{'markup'}
        }, $class;
        return $s;
    }

    sub render {
        my ($s) = @_;
        return int rand $s->{template}{context}->resolve($s->{'max'});
    }
    1;

Using this new tag is as simple as...

    use Template::Liquid;
    use Template::Solution::Tag::Random;

    print Template::Liquid->parse('{% random max %}')->render({max => 30});

This will print a random integer between C<0> and C<30>.

=head2 Creating Your Own Tag Blocks

If you just want a quick sample, see C<examples/custom_tag.pl>. There you'll
find an example C<{^% dump var %}> tag named C<Template::Solution::Tag::Dump>.

Block-like tags are very similar to
L<simple|Template::Liquid::Tag/"Create Your Own Tags">. Inherit from
L<Template::Liquid::Tag|Template::Liquid::Tag> and register your block
L<globally|Solution/"register_tag"> or locally with
L<Template::Liquid|Template::Liquid/"register_tag">.

The only difference is you define an C<end_tag> in your object.

Here's an example...

    package Template::Solution::Tag::Large::Hadron::Collider;
    our @ISA = qw[Template::Liquid::Tag];
    sub import { Template::Liquid::register_tag('lhc', __PACKAGE__) }

    sub new {
        my ($class, $args) = @_;
        my $s = bless {
                          odds     => $args->{'attrs'},
                          name     => 'LHC-' . $args->{'attrs'},
                          tag_name => $args->{'tag_name'},
                          parent   => $args->{'parent'},
                          template => $args->{'template'},
                          markup   => $args->{'markup'},
                          end_tag  => 'end' . $args->{'tag_name'}
        }, $class;
        return $s;
    }

    sub render {
        my ($s) = @_;
        return if int rand $s->{template}{context}->{template}{context}->resolve($s->{'odds'});
        return join '', @{$s->{'nodelist'}};
    }
    1;

Using this example tag...

    use Template::Liquid;
    use Template::Solution::Tag::Large::Hadron::Collider;

    warn Template::Liquid->parse(q[{% lhc 2 %}Now, that's money well spent!{% endlhc %}])->render();

Just like the real thing, our C<lhc> tag works only 50% of the time.

The biggest changes between this and the
L<random tag|Solution/"Create Your Own Tags"> we build above are in the
constructor.

The extra C<end_tag> attribute in the object's reference lets the parser know
that this is a block that will slurp until the end tag is found. In our
example, we use C<'end' . $args->{'tag_name'}> because you may eventually
subclass this tag and let it inherit this constructor. Now that we're sure the
parser knows what to look for, we go ahead and continue
L<parsing|Template::Liquid/"parse"> the list of tokens. The parser will shove
child nodes (L<tags|Template::Liquid::Tag>, L<variables|Template::Liquid::Variable>, and
simple strings) onto your stack until the C<end_tag> is found.

In the render step, we must return the stringification of all child nodes
pushed onto the stack by the parser.

=head2 Creating Your Own Conditional Tag Blocks

The internals are still kinda rough around this bit so documenting it is on my
TODO list. If you're a glutton for punishment, I guess you can skim the source
for the L<if tag|Template::Liquid::Tag::If> and its subclass, the
L<unless tag|Template::Liquid::Tag::Unless>.

=head1 Author

Sanko Robinson <sanko@cpan.org> - http://sankorobinson.com/

The original Liquid template system was developed by jadedPixel
(http://jadedpixel.com/) and Tobias Lütke (http://blog.leetsoft.com/).

=head1 License and Legal

Copyright (C) 2009-2012 by Sanko Robinson E<lt>sanko@cpan.orgE<gt>

This program is free software; you can redistribute it and/or modify it under
the terms of The Artistic License 2.0.  See the F<LICENSE> file included with
this distribution or http://www.perlfoundation.org/artistic_license_2_0.  For
clarification, see http://www.perlfoundation.org/artistic_2_0_notes.

When separated from the distribution, all original POD documentation is
covered by the Creative Commons Attribution-Share Alike 3.0 License.  See
http://creativecommons.org/licenses/by-sa/3.0/us/legalcode.  For
clarification, see http://creativecommons.org/licenses/by-sa/3.0/us/.

=cut
