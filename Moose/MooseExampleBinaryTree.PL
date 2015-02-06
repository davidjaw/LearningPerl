package BinaryTree;
use Moose;
has 'node' => (is => 'rw', isa => 'Any');
has 'parent' => (
  is => 'rw',
  isa => 'BinaryTree',
  predicate => 'has_parent',
  weak_ref => 1,
);
has 'left' => (
  is => 'rw',
  isa => 'BinaryTree',
  predicate => 'has_left',
  lazy => 1,
  builder => '_build_child_tree',
);
has 'right' => (
  is => 'rw',
  isa => 'BinaryTree',
  predicate => 'has_right',
  lazy => 1,
  builder => '_build_child_tree',
);
before 'right', 'left' => sub {
  my ($self, $tree) = @_;
  $tree->parent($self) if defined $tree;
};
sub _build_child_tree {
  my $self = shift;
  return BinaryTree->new( parent => $self );
}
__PACKAGE__->meta->make_immutable;

package main;
use v5.18.2;
use Data::Dumper;

my $tree = BinaryTree->new;
my $left = $tree->left;
my $tree2 = BinaryTree->new;
my $left2 = $tree2->left;
my $right = $left->left($tree2);
print Dumper $left;

__END__
Dumper內容：
$VAR1 = bless( {
  'left' => bless( {
    'parent' => $VAR1,
    'left' => bless( {
      'parent' => $VAR1->{'left'}
    }, 'BinaryTree' )
  }, 'BinaryTree' ),
  'parent' => bless( {
    'left' => $VAR1
  }, 'BinaryTree' )
}, 'BinaryTree' );
