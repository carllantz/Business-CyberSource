package Business::CyberSource::Request::Role::Common;
use 5.008;
use strict;
use warnings;
use Carp;
use namespace::autoclean;

# VERSION

use Moose::Role;
use MooseX::Types::Moose   qw( HashRef Str );
use MooseX::Types::URI     qw( Uri     );
use MooseX::Types::Path::Class qw( File Dir );
use MooseX::SetOnce 0.200001;

with qw(
	Business::CyberSource::Request::Role::Credentials
	Business::CyberSource::Request::Role::PurchaseInfo
	Business::CyberSource::Role::MerchantReferenceCode
);

use Business::CyberSource::Client;

sub serialize {
	my $self = shift;
	return $self->_request_data;
}

sub submit {
	my $self = shift;

	my $client = Business::CyberSource::Client->new({
		username   => $self->username,
		password   => $self->password,
		production => $self->production,
	});

	return $client->run_transaction( $self );
}

sub BUILD { ## no critic qw( Subroutines::RequireFinalReturn )
	my $self = shift;

	if ( $self->does('Business::CyberSource::Request::Role::PurchaseInfo' ) ) {
		unless ( $self->has_items or $self->has_total ) {
			croak 'you must define either items or total';
		}
	}

	if ( $self->does('Business::CyberSource::Request::Role::BillingInfo' ) ) {
		if ( $self->country eq 'US' or $self->country eq 'CA' ) {
			croak 'zip code is required for US or Canada'
				unless $self->has_zip;
		}
	}
}

has comments => (
	is       => 'ro',
	isa      => Str,
	trigger  => sub {
		my $self = shift;
		$self->_request_data->{comments} = $self->comments;
	},
);

has trace => (
	is       => 'rw',
	isa      => 'XML::Compile::SOAP::Trace',
	traits   => [ 'SetOnce' ],
	init_arg => undef,
	writer   => '_trace',
);

has _request_data => (
	required => 1,
	init_arg => undef,
	is       => 'rw',
	isa      => HashRef,
	default => sub { { } },
);

1;

# ABSTRACT: Request Role

=for Pod::Coverage BUILD
=cut
