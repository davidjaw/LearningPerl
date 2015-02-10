#!/use/bin/perl
use Data::Dumper;
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
  sub BUILD {
    my ($self, $ref) = @_;
    my $content = '';
    $content = $1 if $ref->{content} =~/\[\[(.+)/;
    my $job = '';
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
    $self->job($job) if $job ne '';
    $self->gossip($content) if $content ne '' && $content !~ m'(歌)|(盜)|(傭)|(富)|(豪)|(壕)|(非)';
  }
  has 'ID' => ( is => 'ro', isa => 'Str' );
  has 'shownTimes' => ( is => 'rw', isa => 'Int' );
  has 'content' => ( is => 'rw', isa => 'Str');
  has 'job' => ( is => 'rw', isa => 'Str', predicate => 'hasJob');
  has 'gossip' => ( is => 'rw', isa => 'Str', predicate => 'hasGossip');
  sub sortID {
    return @{$ID->{Refs}};
  }
  1;
}

use v5.18.2;
my $agent = Chat->new;

while(<DATA>){
  $agent->add($_);
}
for my $self(Chat::ID->sortID){
  say 'ID: ', $self->ID;
  say 'Job: ', $self->job if $self->hasJob;
  say 'Gossip: ', $self->gossip if $self->hasGossip;
  say 'Shwontimes: ', $self->shownTimes;
  say "";
}
__DATA__
23:21 kenny 紅水要怎麼喝==？[[asdf
23:21 張富翔 6C 打一次26K
23:21 張富翔 去倉庫喝
23:21 Sih_Yuan ……
23:21 david 趙 好問題ww
23:21 張富翔 全噴
23:22 kenny 可是點倉庫只有硬幣欸
23:22 Sih_Yuan 晚上有這麼難組野團嗎==
23:22 Jacky （つばさ） e開？
23:22 kenny 沒看到紅水
23:22 david 趙 那就是你沒有水
23:22 張富翔 你是當天送的??
23:22 david 趙 MENU 下面那牌有個購物車[[歌姬
23:22 張富翔 還是用石頭買的
23:22 kenny 送的
23:22 E 我開？
23:22 kenny 那有時間限制？
23:22 Jacky （つばさ） 嗯
23:22 張富翔 送的只有當天
23:22 david 趙 送的過11點就消失了