package Business::CyberSource::Request::Credit;
use 5.008;
use strict;
use warnings;
use Carp;

# VERSION

use Moose;
use namespace::autoclean;
with qw(
	MooseX::Traits
	Business::CyberSource::Request::Role::Common
	Business::CyberSource::Request::Role::PurchaseInfo
);

use Business::CyberSource::Response;

has '+_trait_namespace' => (
	default => 'Business::CyberSource::Request::Role',
);

has request_id => (
	is  => 'ro',
	isa => 'Str',
);

sub submit {
	my $self = shift;

	my $payload = {
		ccCreditService => {
			run => 'true',
			captureRequestID => $self->request_id,
		},
	};

	if ( $self->does('Business::CyberSource::Request::Role::BillingInfo') ) {
		$payload->{billTo} = $self->_billing_info ;
	}

	if ( $self->does('Business::CyberSource::Request::Role::CreditCardInfo') ) {
		$payload->{card} = $self->_cc_info ;
	}

	my $r = $self->_build_request( $payload );

	my $res;
	if ( $r->{decision} eq 'ACCEPT' ) {
		$res
			= Business::CyberSource::Response
			->with_traits(qw{
				Business::CyberSource::Response::Role::Accept
				Business::CyberSource::Response::Role::Credit
			})
			->new({
				request_id     => $r->{requestID},
				decision       => $r->{decision},
				# quote reason_code to stringify from BigInt
				reason_code    => "$r->{reasonCode}",
				reference_code => $r->{merchantReferenceCode},
				currency       => $r->{purchaseTotals}->{currency},
				datetime       => $r->{ccCreditReply}->{requestDateTime},
				amount         => $r->{ccCreditReply}->{amount},
				credit_reason_code => "$r->{ccCreditReply}->{reasonCode}",
				reconciliation_id  => $r->{ccCreditReply}->{reconciliationID},
			})
			;
	}
	elsif ( $r->{decision} eq 'REJECT' ) {
		$res
			= Business::CyberSource::Response
			->with_traits(qw{
				Business::CyberSource::Response::Role::Reject
			})
			->new({
				decision      => $r->{decision},
				request_id    => $r->{requestID},
				reason_code   => "$r->{reasonCode}",
				request_token => $r->{requestToken},
			})
			;
	}
	else {
		croak 'decision defined, but not sane: ' . $r->{decision};
	}

	return $res;
}

__PACKAGE__->meta->make_immutable;
1;

# ABSTRACT: CyberSource Credit Request Object

=head1 SYNOPSIS

	use Business::CyberSource::Request::Credit;

	my $req = Business::CyberSource::Request::Credit
		->with_traits(qw{
			BillingInfo
			CreditCardInfo
		})
		->new({
			username       => 'merchantID',
			password       => 'transaction key',
			production     => 0,
			reference_code => 'merchant reference code',
			first_name     => 'Caleb',
			last_name      => 'Cushing',
			street         => 'somewhere',
			city           => 'Houston',
			state          => 'TX',
			zip            => '77064',
			country        => 'US',
			email          => 'xenoterracide@gmail.com',
			total          => 5.00,
			currency       => 'USD',
			credit_card    => '4111-1111-1111-1111',
			cc_exp_month   => '09',
			cc_exp_year    => '2025',
		});

	my $res = $req->submit;

=head1 DESCRIPTION

This object allows you to create a request for a credit. Their are two types
of credits, a standalone credit, and a follow on credit.

=method with_traits

For standalone credit requests requests you need to apply C<BillingInfo> and
C<CreditCardInfo> roles. This is not necessary for follow on credits. Follow
on credits require that you specify a C<request_id> in order to work.

=method new

Instantiates a credit request object, see L<the attributes listed below|/ATTRIBUTES>
for which ones are required and which are optional.

=method submit

Actually sends the required data to CyberSource for processing and returns a
L<Business::CyberSource::Response> object.

=head1 SEE ALSO

=over

=item * L<Business::CyberSource::Request>

=back

=cut
