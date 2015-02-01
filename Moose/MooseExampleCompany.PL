# 一些基礎運用 subtype, after ...
package Company;
use Moose;
use Moose::Util::TypeConstraints;
has 'name' => ( is => 'rw', isa => 'Str', required => 1 );
has 'address'   => ( is => 'rw', isa => 'Str' );
has 'employees' => (
    is      => 'rw',
    isa     => 'ArrayRef[Employee]',
    default => sub { [] },
);
sub BUILD { # called when new a company
    my ( $self, $params ) = @_;
    foreach my $employee ( @{ $self->employees } ) {
        $employee->employer($self);
    }
}
after 'employees' => sub { # called after adding employees to company
    my ( $self, $employees ) = @_;
    return unless $employees;
    foreach my $employee ( @$employees ) {
        $employee->employer($self);
    }
};
package Person;
use Moose;
has 'first_name' => ( is => 'rw', isa => 'Str', required => 1 );
has 'last_name'  => ( is => 'rw', isa => 'Str', required => 1 );
has 'middle_initial' => (
    is        => 'rw', isa => 'Str',
    predicate => 'has_middle_initial'
);
has 'address' => ( is => 'rw', isa => 'Str' );
sub full_name {
    my $self = shift;
    return $self->first_name . (
        $self->has_middle_initial
        ? ' ' . $self->middle_initial . '. '
        : ' '
        ) . $self->last_name;
}
package Employee;
use Moose;
extends 'Person';
has 'title'    => ( is => 'rw', isa => 'Str',     required => 1 );
has 'employer' => ( is => 'rw', isa => 'Company', weak_ref => 1 );
override 'full_name' => sub {
    my $self = shift;
    super() . ', ' . $self->title;
};

package main;
use v5.18.2;
use Data::Dumper;

my $man = Employee->new(title => 'fk', last_name => 'dada', first_name => 'aaaa');
my $man2 = Employee->new(title => 'fk', last_name => 'dddddd', first_name => 'vvvv');
my $company = Company->new( name => 'da', employees => [$man, $man2]);
print Dumper $company;
