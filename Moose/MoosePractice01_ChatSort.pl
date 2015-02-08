use v5.18.2;
use Data::Dumper;
package Chat{
  use Moose;
  use Moose::Util::TypeConstraints;
  my @Chater;
  coerce 'Chat::ID'
    => from 'Str'
    => via { Chat::ID->new( content => $_) };
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
  coerce 'Chat::ID::Content'
    => from 'Str'
    => via { Chat::ID::Content->new( content => $_) };
  has 'content' => ( is => 'rw', isa => 'Chat::ID::Content', coerce => 1);
  1;
}
package Chat::ID::Content {
  use Moose;
  use Moose::Util::TypeConstraints;
  has 'content' => ( is => 'rw', isa => 'Str');
  1;
}
use Data::Dumper;
my $agent = Chat->new;
while(<DATA>){
  $agent->add($_);
}
print Dumper $agent;
__DATA__
23:21 kenny 紅水要怎麼喝==？
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
23:22 david 趙 MENU 下面那牌有個購物車
23:22 張富翔 還是用石頭買的
23:22 kenny 送的
23:22 E 我開？
23:22 kenny 那有時間限制？
23:22 Jacky （つばさ） 嗯
23:22 張富翔 送的只有當天
23:22 david 趙 送的過11點就消失了