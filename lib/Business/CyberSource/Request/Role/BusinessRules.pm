package Business::CyberSource::Request::Role::BusinessRules;
use 5.008;
use strict;
use warnings;
use namespace::autoclean;

# VERSION

use Moose::Role;
use MooseX::Types::Moose qw( Bool ArrayRef Int );
use MooseX::Types::CyberSource qw( AVSResult );

has ignore_avs_result => (
	predicate => 'has_ignore_avs_result',
	required  => 0,
	is        => 'ro',
	isa       => Bool,
);

has ignore_cv_result => (
	predicate => 'has_ignore_cv_result',
	required  => 0,
	is        => 'ro',
	isa       => Bool,
);

has ignore_dav_result => (
	predicate => 'has_ignore_dav_result',
	required  => 0,
	is        => 'ro',
	isa       => Bool,
);

has ignore_export_result => (
	predicate => 'has_ignore_export_result',
	required  => 0,
	is        => 'ro',
	isa       => Bool,
);

has ignore_validate_result => (
	predicate => 'has_ignore_validate_result',
	required  => 0,
	is        => 'ro',
	isa       => Bool,
);

has decline_avs_flags => (
	predicate => 'has_decline_avs_flags',
	required  => 0,
	isa       => ArrayRef[AVSResult],
	traits    => ['Array'],
	handles   => {
		_stringify_decline_avs_flags => [ join => ' ' ],
	},
);

has score_threshold => (
	predicate => 'has_score_threshold',
	required  => 0,
	isa       => Int,
);

sub _business_rules {
	my $self = shift;

	my $i = { };

	$i->{scoreThreshold} = $self->score_threshold
		if $self->has_score_threshold;

	$i->{declineAVSFlags} = $self->_stringify_decline_avs_flags
		if $self->has_decline_avs_flags;

	if ( $self->has_ignore_validate_result ) {
		$i->{ignoreValidateResult}
			= $self->ignore_validate_result ? 'true' : 'false';
	}

	if ( $self->has_ignore_export_result ) {
		$i->{ignoreExportResult}
			= $self->ignore_export_result ? 'true' : 'false';
	}

	if ( $self->has_ignore_dav_result ) {
		$i->{ignoreDAVResult}
			= $self->ignore_dav_result ? 'true' : 'false';
	}

	if ( $self->has_ignore_cv_result ) {
		$i->{ignoreCVResult}
			= $self->ignore_cv_result ? 'true' : 'false';
	}

	if ( $self->has_ignore_avs_result ) {
		$i->{ignoreAVSResult}
			= $self->ignore_avs_result ? 'true' : 'false';
	}

	return $i;
}
1;

# ABSTRACT: Business Rules Role