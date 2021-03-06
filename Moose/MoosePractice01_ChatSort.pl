#!/use/bin/perl
package Chat{
  use Moose;
  use Moose::Util::TypeConstraints;
  my @Chater;
  coerce 'Chat::ID'
    => from 'Str'
    => via {
      my $self = shift;
      my ($ID, $content) = m'[\S]+ (.+?) (.*)$';
      return Chat::ID->new( ID => $ID, content => $content) };
  has 'id' => ( is => 'rw', isa => 'Chat::ID', coerce => 1);
  sub add {
    my ($self, $content) = @_;
    $self->id( $content );
  }
  1;
}
package Chat::ID{
  use Moose;
  use Moose::Util::TypeConstraints;
  my $ID;
  $ID->{maxLength} = 0;
  sub BUILD {
    my ($self, $ref) = @_;
    my ($content, $job)= ('', '');
    $content = $1 if $ref->{content} =~/\[\[(.+)/;
    $job = $content if m'(歌)|(盜)|(傭)|(富)|(豪)|(壕)|(非)';
    if(exists $ID->{$ref->{ID}}){
      $self = $ID->{$ref->{ID}};
      $self->shownTimes( $self->shownTimes + 1);
    }
    else {
      $ID->{$ref->{ID}} = $self;
      push @{$ID->{Refs}}, $self;
      $self->shownTimes(1);
    }
    $ID->{totalTalk}++;
    $ID->{maxLength} = getLength($ref->{ID}) if getLength($ref->{ID}) > $ID->{maxLength};
    $self->addJob($job) if $job ne '';
    $self->addGossip($content) if $content ne '' && $content !~ m'(歌)|(盜)|(傭)|(富)|(豪)|(壕)|(非)';
  }
  has 'ID' => ( is => 'rw', isa => 'Str' );
  has 'shownTimes' => ( is => 'rw', isa => 'Int' );
  has 'content' => ( is => 'rw', isa => 'Str');
  has 'job' => ( is => 'rw', isa => 'ArrayRef', predicate => 'hasJob');
  has 'gossip' => ( is => 'rw', isa => 'ArrayRef', predicate => 'hasGossip');
  sub sortID { return @{$ID->{Refs}}; }
  sub totalTalk { return $ID->{totalTalk}; }
  sub clear { $ID = ''; }
  sub addJob{
    my ($self, $add) = @_;
    push @{$self->job}, $add if $self->hasJob;
    $self->job( [$add] ) unless $self->hasJob;
  }
  sub addGossip{
    my ($self, $add) = @_;
    push @{$self->gossip}, $add if $self->hasGossip;
    $self->gossip( [$add] ) unless $self->hasGossip;
  }
  sub getLength {
    my $string = shift;
    my $spaceNum = 0;
    for( split '', $string ){
      if( length $_ == 3 ){ $spaceNum += 2; }
      elsif( length $_ == 1 ){ $spaceNum++; }
    }
    return $spaceNum;
  }
  sub ganerateLength {
    for my $self (@{$ID->{Refs}}){
      my $selfLength = getLength($self->ID);
      if( $selfLength < $ID->{maxLength} ){
        for(0..$ID->{maxLength} - $selfLength){
          my $ID = $self->ID . " ";
          $self->ID( $ID );
        }
      }
    }
  }
  1;
}

use v5.18.2;
my $agent = Chat->new;

# for my $fileName( glob 'list*.txt' ){
  # open my $FH, $_;
  # while(<$FH>){
    # chomp;
    # $agent->add($_);
  # }
  # close($FH)
# }
# Chat::ID->clear;
open my $FH, 'today.txt';
while(<$FH>){ $agent->add($_) if /[\S]+ .+ .+/; }
Chat::ID->ganerateLength;
close($FH);
open my $jobHandle, '>Job';
open my $gossipHandle, '>Gossips';
makeList($jobHandle, 1);
makeList($gossipHandle, 0);
sub makeList{
  my ($FH, $method) = @_;
  for my $self(sort { $a->shownTimes <=> $b->shownTimes } Chat::ID->sortID){
    print $FH '---ID: ', $self->ID if $method || (!$method && $self->hasGossip);
    say $FH '' if (!$method && $self->hasGossip);
    say $FH "\tTalks: ", $self->shownTimes if $method;
    if($self->hasJob && $method){
      say $FH " └ $_" for(@{$self->job});
    }
    if($self->hasGossip && !$method){
      say $FH " └ $_" for(@{$self->gossip});
    }
  }
  say $FH 'Total: ', Chat::ID->totalTalk if $method;
}
