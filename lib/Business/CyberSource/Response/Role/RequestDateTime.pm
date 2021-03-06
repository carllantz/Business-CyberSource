package Business::CyberSource::Response::Role::RequestDateTime;
use strict;
use warnings;
use namespace::autoclean;
use Module::Load qw( load );

# VERSION

use Moose::Role;
use MooseX::RemoteHelper;
use MooseX::Types::CyberSource qw( DateTimeFromW3C );

has datetime => (
	isa         => DateTimeFromW3C,
	remote_name => 'requestDateTime',
	is          => 'ro',
	coerce      => 1,
	predicate   => 'has_datetime',
);

1;

# ABSTRACT: Role to provide datetime attribute

=head1 DESCRIPTION

Several responses include a datetime that has a key name of C<requestDateTime>
this role is provided for those response sections.

=cut
