package Games::FrogJump::Board;
use 5.012;
use Moo;

use Text::Wrap;
use if $^O eq "MSWin32", "Win32::Console::ANSI";
use Term::ANSIColor;
use List::Util qw/max min/;
use Color::ANSI::Util qw/ansifg ansibg/;

has stone_number  => is => 'rw', default => 7;
has stone_width   => is => 'rw', default => 7;
has stone_gap     => is => 'rw', default => 2;

has border_width  => is => 'rw', default => 2;
has border_height => is => 'rw', default => 1;
has border_color  => is => 'rw', default => color('reverse');
has content_width => is => 'rw', default => 70;
has content_height => is => 'rw', default => 13;

has _frogs       => is => 'lazy';
has current_frog => is => 'rw', default => '';

sub draw {
    my ( $self, $redraw ) = @_;

    $self->hide_cursor;
    $self->draw_guide;
    $self->draw_border;
    $self->draw_stone;
    $self->draw_frog;
    $self->draw_title;

}

sub draw_frog {
    my $self = shift;
    $self->save_cursor;
    $self->move_cursor(6, $self->content_height-1);
    foreach my $index ( 0..$self->stone_number-1 ){
        my $frog = $self->frog_on_stone($index);
        my $gap;
        my $blank;
        my $frog_graph = $frog->graph;
        $blank = ' ' x ( ( $self->stone_width - $frog->width ) / 2);
        $frog_graph = $blank . $frog_graph . $blank;
        $gap   = ' ' x $self->stone_gap;
        print $frog_graph;
        print $gap;
    }
    say '';
    $self->restore_cursor;
}

sub draw_stone {
    my ( $self )  = @_;
    $self->save_cursor;
    $self->move_cursor(6, $self->content_height);
    foreach my $index ( 0..$self->stone_number-1 ){
        my $stone;
        my $gap;
        $stone = ' ' x $self->stone_width;
        $stone = color('reverse cyan'). $stone . color('reset');
        $gap   = ' ' x $self->stone_gap;
        print $stone;
        print $gap;
    }
    $self->restore_cursor;
}

sub draw_guide {
    my $self = shift;
    $self->save_cursor;
    $self->move_cursor($self->content_width-15, 2);
    print color('green') . '<-' . color('reset') . ' : select frog';
    $self->move_cursor(-16, 1);
    print color('green') . '->' . color('reset') . ' : select frog';
    $self->move_cursor(-16, 1);
    print color('green') . 'sp' . color('reset') . ' : jump       ';
    $self->move_cursor(-16, 1);
    print color('green') . 'r ' . color('reset') . ' : restart    ';
    $self->move_cursor(-16, 1);
    print color('green') . 'q ' . color('reset') . ' : quit       ';
    $self->restore_cursor;
}

sub draw_title {
    my $self = shift;
    $self->save_cursor;
    $self->move_cursor(30, 2);
    print color('green') . 'Frog Jump --_' . color('reset');
    $self->restore_cursor;
}

sub draw_win {
    my $self = shift;
    $self->save_cursor;
    $self->move_cursor(30, 2);
    print color('green') . 'You  Win  @@_' . color('reset');
    $self->restore_cursor;
}

sub draw_quit {
    my $self = shift;
    $self->move_cursor(0, $self->content_height + 5);
    say color('reset') . '';
    $self->show_cursor;
}
sub draw_border {
    my $self = shift;
    $self->save_cursor;
    say $self->border_color, " " x $self->board_width, color("reset") for 1..$self->border_height;
    foreach my $col ( 0..$self->content_height-1 ){
        print $self->border_color, " " x $self->border_width, color("reset");
        $self->move_cursor(70, 0);
        print $self->border_color, " " x $self->border_width, color("reset");
        print "\n";
    }

    say $self->border_color, " " x $self->board_width, color("reset") for 1..$self->border_height;
    $self->restore_cursor;
}

sub board_width {
    my $self = shift;
    return $self->content_width + $self->border_width * 2;
}

sub move_cursor {
    my ( $self, $dx, $dy ) = @_;
    $dx > 0 ? do { printf "\e[%dC", $dx } : $dx < 0 ? do { printf "\e[%dD", -$dx } : do {};
    $dy > 0 ? do { printf "\e[%dB", $dy } : $dy < 0 ? do { printf "\e[%dA", -$dy } : do {};
}

sub save_cursor {
    my $self = shift;
    print "\e[s";
}

sub restore_cursor {
    my $self = shift;
    print "\e[u";
}

sub hide_cursor {
    my $self = shift;
    state $once = eval 'END { $self->show_cursor }';
    print "\e[?25l";
}
sub show_cursor {
    my $self = shift;
    print "\e[?25h";
}

sub clear_screen {
    my $self = shift;
    print "\e[1J";
    print "\e[1;1H";
}

sub get_frog {
    my $self = shift;
    my $n    = shift;
    return $self->_frogs->[$n];
}

sub set_frog {
    my ( $self, $index, $frog )= @_;
    $self->_frogs->[$index] = $frog;
}

sub frog_on_stone {
    my ( $self, $stone_n ) = @_;
    foreach my $n ( 0..$self->stone_number-1 ){
        my $frog = $self->get_frog($n);
        return $frog if $frog->stone_index == $stone_n and $frog->direction ne 'null';
    }
    my $null_frog = Games::FrogJump::Frog->new();
    return $null_frog;
}

sub _build__frogs {
    my $self = shift;
    [ 1..$self->stone_number ];
}

sub set_current_frog {
    my ( $self, $frog ) = @_;
    $self->current_frog->unactive if $self->current_frog ne '';
    $self->current_frog($frog);
    $frog->active;
}

1;
