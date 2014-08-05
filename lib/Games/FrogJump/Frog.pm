package Games::FrogJump::Frog;
use 5.012;
use Moo;
use if $^O eq "MSWin32", "Win32::Console::ANSI";
use Term::ANSIColor;

has direction    => is => 'ro', default => 'null';
has stone_index  => is => 'rw', default => -1;
has width        => is => 'rw', default => 3;
has bg_color     => is => 'rw', default => 'on_black';
has fr_color     => is => 'rw', default => 'blue';
has stored_ansi  => is => 'rw';
has ansi         => is => 'rw', default => '   ';

sub graph {
    my $self = shift;
    return color( $self->fr_color . ' ' . $self->bg_color ) . $self->ansi . color('reset');
}

sub active {
    my $self = shift;
    $self->fr_color('red');
    $self->stored_ansi($self->ansi);
    $self->ansi('@@_') if $self->direction eq 'left';
    $self->ansi('_@@') if $self->direction eq 'right';
}

sub unactive {
    my $self = shift;
    $self->fr_color('blue');
    $self->ansi($self->stored_ansi);
}

sub jump_left {
    my ( $self, $step ) = @_;
    $self->stone_index($self->stone_index - $step);
}

sub jump_right {
    my ( $self, $step ) = @_;
    $self->stone_index($self->stone_index + $step);
}
1;
