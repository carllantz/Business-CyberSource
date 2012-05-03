package Business::CyberSource::Request::Capture;
use strict;
use warnings;
use namespace::autoclean;

# VERSION

use Moose;
with qw(
	Business::CyberSource::Request::Role::Common
	Business::CyberSource::Request::Role::FollowUp
	Business::CyberSource::Request::Role::DCC
);

before serialize => sub {
	my $self = shift;

	$self->_request_data->{ccCaptureService}{run} = 'true';
	$self->_request_data->{ccCaptureService}{authRequestID}
		= $self->request_id
		;
};

__PACKAGE__->meta->make_immutable;
1;

# ABSTRACT: CyberSource Capture Request Object

=head1 SYNOPSIS

	my $capture = Business::CyberSource::Request::Capture->new({
		username       => 'merchantID',
		password       => 'transaction key',
		production     => 0,
		reference_code => 'merchant reference code',
		request_id     => 'authorization response request_id',
		total          => 5.01,  # same amount as in authorization
		currency       => 'USD', # same currency as in authorization
	});

=head1 DESCRIPTION

This object allows you to create a request for a capture.

=method new

Instantiates a authorization reversal request object, see
L<the attributes listed below|/ATTRIBUTES> for which ones are required and
which are optional.

=method submit

Actually sends the required data to CyberSource for processing and returns a
L<Business::CyberSource::Response> object.

=head1 SEE ALSO

=over

=item * L<Business::CyberSource::Request>

=back

=cut
