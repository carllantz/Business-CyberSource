package MooseX::Types::CyberSource;
use strict;
use warnings;
use Class::Load 0.20 qw( load_class );
use namespace::autoclean;

# VERSION

use MooseX::Types -declare => [ qw(
	AVSResult
	CardTypeCode
	CountryCode
	CvIndicator
	CvResults
	DCCIndicator

	Decision
	Items

	Item
	Card
	PurchaseTotals
	Service
	AuthReversalService
	CaptureService
	CreditService
	TaxService
	BillTo
	BusinessRules

	ResPurchaseTotals

	RequestID

	ExpirationDate
	CreditCard

	_VarcharOne
	_VarcharSeven
	_VarcharTen
	_VarcharTwenty
	_VarcharFifty
	_VarcharSixty
) ];

use MooseX::Types::Common::Numeric qw( PositiveOrZeroNum                       );
use MooseX::Types::Common::String  qw( NonEmptySimpleStr                       );
use MooseX::Types::Moose           qw( Int Num Str HashRef ArrayRef            );
use MooseX::Types::Locale::Country qw( Alpha2Country Alpha3Country CountryName );
use MooseX::Types::DateTime;


enum Decision, [ qw( ACCEPT REJECT ERROR REVIEW ) ];

# can't find a standard on this, so I assume these are a cybersource thing
enum CardTypeCode, [ qw(
	001
	002
	003
	004
	005
	006
	007
	014
	021
	024
	031
	033
	034
	035
	036
	037
	039
	040
	042
	043
) ];

enum CvIndicator, [ qw( 0 1 2 9 ) ];

enum CvResults, [ qw( D I M N P S U X 1 2 3 ) ];

enum AVSResult, [ qw( A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 1 2 ) ];

my $prefix = 'Business::CyberSource::';
my $req    =  $prefix . 'RequestPart::';
my $res    =  $prefix . 'ResponsePart::';

my $itc = $req . 'Item';
my $ptc = $req . 'PurchaseTotals';
my $svc = $req . 'Service';
my $cdc = $req . 'Card';
my $btc = $req . 'BillTo';
my $brc = $req . 'BusinessRules';
my $ars = $req . 'Service::AuthReversal';
my $cps = $req . 'Service::Capture';
my $cds = $req . 'Service::Credit';
my $txs = $req . 'Service::Tax';

my $res_pt_c = $res . 'PurchaseTotals';

class_type Item,                { class => $itc };
class_type PurchaseTotals,      { class => $ptc };
class_type Service,             { class => $svc };
class_type Card,                { class => $cdc };
class_type BillTo,              { class => $btc };
class_type BusinessRules,       { class => $brc };

class_type AuthReversalService, { class => $ars };
class_type CaptureService,      { class => $cps };
class_type CreditService,       { class => $cds };
class_type TaxService,          { class => $txs };

class_type ResPurchaseTotals,   { class => $res_pt_c };

coerce Item,                from HashRef, via { load_class( $itc      )->new( $_ ) };
coerce PurchaseTotals,      from HashRef, via { load_class( $ptc      )->new( $_ ) };
coerce Service,             from HashRef, via { load_class( $svc      )->new( $_ ) };
coerce AuthReversalService, from HashRef, via { load_class( $ars      )->new( $_ ) };
coerce CaptureService,      from HashRef, via { load_class( $cps      )->new( $_ ) };
coerce CreditService,       from HashRef, via { load_class( $cds      )->new( $_ ) };
coerce TaxService,          from HashRef, via { load_class( $txs      )->new( $_ ) };
coerce Card,                from HashRef, via { load_class( $cdc      )->new( $_ ) };
coerce BillTo,              from HashRef, via { load_class( $btc      )->new( $_ ) };
coerce BusinessRules,       from HashRef, via { load_class( $brc      )->new( $_ ) };
coerce ResPurchaseTotals,   from HashRef, via { load_class( $res_pt_c )->new( $_ ) };

subtype CountryCode,
	as Alpha2Country
	;

coerce CountryCode,
	from Alpha3Country,
	via {
		load_class('Locale::Code');

		return uc Locale::Code::country_code2code( $_ ,
			Locale::Code::LOCALE_CODE_ALPHA_3(),
			Locale::Code::LOCALE_CODE_ALPHA_2(),
		);
	}
	;

coerce CountryCode,
	from CountryName,
	via {
		load_class('Locale::Code');
		return uc Locale::Code::country_code2code( $_ ,
			Locale::Code::LOCALE_CODE_ALPHA_2(),
		);
	};

enum DCCIndicator, [ qw( 1 2 3 ) ];

class_type CreditCard, { class => 'Business::CyberSource::CreditCard' };

coerce CreditCard,
	from HashRef,
	via {
		return use_module('Business::CyberSource::CreditCard')->new( $_ );
	};

subtype ExpirationDate, as MooseX::Types::DateTime::DateTime;

coerce ExpirationDate,
	from HashRef,
	via {
		return DateTime->last_day_of_month( %{ $_ } );
	};

subtype RequestID,
	as NonEmptySimpleStr,
	where { length $_ <= 29 }
	;

subtype Items, as ArrayRef[Item];

coerce Items,
	from ArrayRef[HashRef],
	via {
		load_class( $itc );

		my $items = $_;

		my @items = map { $itc->new( $_ ) } @{ $items };
		return \@items;
	};

subtype _VarcharOne,
	as NonEmptySimpleStr,
	where { length $_ <= 1 }
	;

subtype _VarcharSeven,
	as NonEmptySimpleStr,
	where { length $_ <= 7 }
	;

subtype _VarcharTen,
	as NonEmptySimpleStr,
	where { length $_ <= 10 }
	;

subtype _VarcharTwenty,
	as NonEmptySimpleStr,
	where { length $_ <= 20 }
	;

subtype _VarcharFifty,
	as NonEmptySimpleStr,
	where { length $_ <= 50 }
	;

subtype _VarcharSixty,
	as NonEmptySimpleStr,
	where { length $_ <= 60 }
	;
1;

# ABSTRACT: Moose Types specific to CyberSource

=begin Pod::Coverage

LOCALE_CODE_ALPHA_2

LOCALE_CODE_ALPHA_3

=end Pod::Coverage

=cut

=head1 SYNOPSIS

	{
		package My::CyberSource::Response;
		use Moose;
		use MooseX::Types::CyberSource qw( Decision );

		has decision => (
			is => 'ro',
			isa => Decision,
		);
		__PACKAGE__->meta->make_immutable;
	}

	my $response = My::CyberSource::Response->new({
		decison => 'ACCEPT'
	});

=head1 DESCRIPTION

This module provides CyberSource specific Moose Types.

=head1 TYPES

=over

=item * C<Decision>

Base Type: C<enum>

CyberSource Response Decision

=item * C<CardTypeCode>

Base Type: C<enum>

Numeric codes that specify Card types. Codes denoted with an asterisk* are
automatically detected when using

=item * C<CvResults>

Base Type: C<enum>

Single character code that defines the result of having sent a CVN. See
L<CyberSource's Documentation on Card Verification Results
|http://www.cybersource.com/support_center/support_documentation/quick_references/view.php?page_id=421>
for more information.

=item * C<AVSResults>

Base Type: C<enum>

Single character code that defines the result of having sent a CVN. See
L<CyberSource's Documentation on AVS Results
|http://www.cybersource.com/support_center/support_documentation/quick_references/view.php?page_id=423>
for more information.

=item * C<DCCIndicator>

Base Type: C<enum>

Single character code that defines the DCC status

=over

=item * C<1>

Converted - DCC is being used.

=item * C<2>

Non-convertible - DCC cannot be used.

=item * C<3>

Declined - DCC could be used, but the customer declined it.

=back

=back

=cut
