package Business::CyberSource::Role::MerchantReferenceCode;
use strict;
use warnings;
use namespace::autoclean;

# VERSION

use Moose::Role;
use MooseX::RemoteHelper;
use MooseX::Types::CyberSource qw( _VarcharFifty );

has reference_code => (
	isa         => _VarcharFifty,
	remote_name => 'merchantReferenceCode',
	required    => 1,
	is          => 'ro',
	predicate   => 'has_reference_code',
);

1;

# ABSTRACT: Generic implementation of MerchantReferenceCode

=attr reference_code

Merchant-generated order reference or tracking number. CyberSource recommends
that you send a unique value for each transaction so that you can perform
meaningful searches for the transaction.

=cut
