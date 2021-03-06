use utf8;
package CiderWebmail::DB;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2012-11-02 15:57:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nEygWAce+kbC+lpSu8Uj7w

=head1 NAME

CiderWebmail::DB

=head1 DESCRIPTION

CiderWebmail saves user settings like the most recently used sort order or From name in an SQL database.
Defaults to SQLite3 root/var/user_settings.sql

=head1 AUTHOR

Stefan Seifert <nine@cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
