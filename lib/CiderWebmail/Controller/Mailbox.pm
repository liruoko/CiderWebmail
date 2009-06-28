package CiderWebmail::Controller::Mailbox;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use CiderWebmail::Mailbox;
use CiderWebmail::Util;
use DateTime;
use URI::QueryParam;

=head1 NAME

CiderWebmail::Controller::Mailbox - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 setup

Gets the selected mailbox from the URI path and sets up the stash.

=cut

sub setup : Chained('/') PathPart('mailbox') CaptureArgs(1) {
    my ( $self, $c, $mailbox ) = @_;
    $c->stash->{folder} = $mailbox;
    $c->stash->{folders_hash}{$mailbox}{selected} = 'selected';
    $c->stash->{uri_compose} = $c->uri_for("/mailbox/$mailbox/compose");
}

my $local_timezone = (eval { DateTime::TimeZone->new(name => "local"); } or 'UTC');

=head2 view

=cut

sub view : Chained('setup') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    my $mailbox = $c->stash->{mbox} ||= CiderWebmail::Mailbox->new($c, {mailbox => $c->stash->{folder}});

    my $sort = ($c->req->param('sort') or 'date');

    my @uids = $mailbox->uids({ sort => [ $sort ] });

    if (defined $c->req->param('start')) {
        my ($start) = $c->req->param('start')  =~ /(\d+)/;
        my ($end) =   $c->req->param('length') =~ /(\d+)/;
        @uids = splice @uids, ($start or 0), ($end or 0);
    }

    my $reverse = $sort =~ s/\Areverse\W+//;

    my %messages = map { ($_->{uid} => {
                %{ $_ },
                uri_view => $c->uri_for("/mailbox/$_->{mailbox}/$_->{uid}"),
                uri_delete => $c->uri_for("/mailbox/$_->{mailbox}/$_->{uid}/delete"),
            }) } @{ $mailbox->list_messages_hash({ uids => \@uids }) };
    my @messages = map $messages{$_}, @uids;

    my @groups;

    foreach (@messages) {
        $_->{head}->{date}->set_time_zone($c->config->{time_zone} or $local_timezone);

        my $name;

        if ($sort eq 'date') {
            $name = $_->{head}->{date}->ymd;
        }

        if ($sort =~ m/(from|to)/) {
            my $address = $_->{head}->{$1}->[0];
            $name = $address ? ($address->name ? $address->address . ': ' . $address->name : $address->address) : 'Unknown';
        }

        if ($sort eq 'subject') {
            $name = $_->{head}->{subject};
        }
        
        if (not @groups or $groups[-1]{name} ne ($name or '')) {
            push @groups, {name => $name, messages => []};
        }

        push @{ $groups[-1]{messages} }, $_;
    }

    DateTime->DefaultLocale($c->config->{language}); # is this really a good place for this?

    if ($sort eq 'date') {
        $_->{name} .= ', ' . DateTime->new(year => substr($_->{name}, 0, 4), month => substr($_->{name}, 5, 2), day => substr($_->{name}, 8))->day_name foreach @groups;
    }

    my $sort_uri = $c->req->uri->clone;
    $c->stash({
        messages        => \@messages,
        uri_quicksearch => $c->uri_for($c->stash->{folder} . '/quicksearch'),
        template        => 'mailbox.xml',
        groups          => \@groups,
        "sort_$sort"    => 1,
        (map {
            $sort_uri->query_param(sort => ($_ eq $sort and not $reverse) ? "reverse $_" : $_);
            ("uri_sorted_$_" => $sort_uri->as_string)
        } qw(from subject date)),
    });
}

=head2 search

Search the mailbox using simple_search

=cut

sub search : Chained('setup') PathPart('quicksearch') {
    my ( $self, $c, $searchfor ) = @_;
    $searchfor ||= $c->req->param('text');

    my $mbox = CiderWebmail::Mailbox->new($c, { mailbox => $c->stash->{folder} });
    $mbox->simple_search({ searchfor => $searchfor });
    
    $c->stash({
        mbox => $mbox,
    });

    $c->forward('view');
}

=head2 create_subfolder

Create a subfolder of this mailbox

=cut

sub create_subfolder : Chained('setup') PathPart {
    my ( $self, $c ) = @_;

    if (my $name = $c->req->param('name')) {
        $c->model('IMAPClient')->create_mailbox($c, {mailbox => $c->stash->{folder}, name => $name});
        $c->res->redirect($c->uri_for('/mailboxes'));
    }

    $c->stash({
        template => 'create_mailbox.xml',
    });
}

=head1 AUTHOR

Mathias Reitinger <mathias.reitinger@loop0.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
