# coerce, subtype, overload, new
package Human;
use Moose;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw/zip/;
coerce 'Human::EyeColor'
	=> from 'ArrayRef'
	=> via { my @genes = qw'bey2_1 bey2_2 gey_1 gey_2';
		return Human::EyeColor->new( zip(@genes, @{$_}) ) };
subtype 'Sex'
	=> as 'Str'
	=> where { $_ =~ /^[mf]$/s };
has 'sex' => ( is => 'ro', isa => 'Sex', required => 1);
has 'mother' => ( is => 'ro', isa => 'Human');
has 'father' => ( is => 'ro', isa => 'Human');
has 'eyeColor' => ( is => 'ro', isa => 'Human::EyeColor', coerce => 1, required => 1 );
use overload '+' => \&_overload_add, fallback => 1;
sub _overload_add {
	my ($one, $two) = @_;
	die "man and wemon can create children\n" if $one->sex() eq $two->sex();
	my ($father, $mother) = ($one->sex() eq 'f')? ($one, $two) : ($two, $one);
	my $sex = 'f'; 
	$sex = 'm' if rand 1 > 0.5;
	
	return Human->new(
		sex => $sex,
		eyeColor => ( $one->eyeColor() + $two->eyeColor() ),
		mother => $mother,
		father => $father,
	);
}
package Human::Gene::bey2;
use Moose;
use Moose::Util::TypeConstraints;

type 'bey2Color' => where { $_ =~ m'^(?:brown|blue)$' };
has 'color' => (is => 'ro', isa => 'bey2Color' );

package Human::Gene::gey;
use Moose;
use Moose::Util::TypeConstraints;

type 'geyColor' => where { $_ =~ m'^(?:green|blue)$' };
has 'color' => (is => 'ro', isa => 'geyColor' );

package Human::EyeColor;
use Moose;
use Moose::Util::TypeConstraints;

coerce 'Human::Gene::bey2'
	=> from 'Str'
		=> via { Human::Gene::bey2->new( color => $_ ) };
coerce 'Human::Gene::gey'
	=> from 'Str'
		=> via { Human::Gene::gey->new( color => $_ ) };

has [ qw'bey2_1 bey2_2' ] =>
	( is => 'ro', isa => 'Human::Gene::bey2', coerce => 1 );
has [ qw'gey_1 gey_2' ] =>
	( is => 'ro', isa => 'Human::Gene::gey', coerce => 1 );

sub color{
	my $self = @_;
	
	return 'brown' if( $self->bey2_1->color() eq 'brown' || $self->bey2_2->color() eq 'brown');
	return 'green' if( $self->gey_1->color() eq 'green' || $self->gey_2->color() eq 'green');
	return 'blue';
}
use overload '""' => \&color, fallback => 1;
use overload '+' => \&_overload_add, fallback => 1;
sub _overload_add {
	my ($one, $two) = @_;
	my $one_bey2 = 'bey2_' . _rand2();
	my $two_bey2 = 'bey2_' . _rand2();
	my $one_gey = 'gey_' . _rand2();
	my $two_gey = 'gey_' . _rand2();
	
	return Human::EyeColor->new(
		bey2_1 => $one->$one_bey2->color(),
		bey2_2 => $two->$two_bey2->color(),
		gey_1 => $one->$one_gey->color(),
		gey_2 => $two->$two_gey->color(),
	);
}
sub _rand2 { return 1 + int rand 2 }

package main;
use Data::Dumper;
use Moose;
use v5.18.2;

my $t = Human->new(sex => 'f', eyeColor => [qw/brown brown green green/]);
my $t2 = Human->new(sex => 'm', eyeColor => [qw/blue blue blue blue/]);
# print Dumper $t;
my $t3 = $t + $t2;
print Dumper $t3;
