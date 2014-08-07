package Games::FrogJump::Game;
use 5.012;
use Moo;

use Storable;
use File::Spec::Functions;
use File::HomeDir;

extends 'Games::FrogJump::Board';

has init_directions   => is => 'ro' => default => sub { [ 'right', 'right', 'right', 'null', 'left', 'left', 'left' ] };
has target_directions => is => 'ro' => default => sub { [ 'left', 'left', 'left', 'null', 'right', 'right', 'right' ] };

sub init {
    my $self = shift;
    my $directions = $self->init_directions;
    foreach my $index ( 0..$self->stone_number - 1 ){
        my $frog = Games::FrogJump::Frog->new(
            direction    => $directions->[$index],
           stone_index  => $index,
            bg_color     => $index < 3  ? 'on_yellow' :
                            $index == 3 ? 'on_black' :
                            'on_green',
            ansi         => $index < 3  ? '_--'  :
                            $index == 3 ? '   ' :
                            '--_',
            );
        $self->set_frog( $index, $frog );
    }
    $self->set_current_frog($self->get_frog(0));
    $SIG{INT} = sub { $self->draw_quit; exit 1 };
    $SIG{__DIE__} = sub { $self->draw_quit; exit 1};
}

sub act {
    my $self = shift;
    my $cmd  = shift;
    if ( $cmd eq 'left' ){
        $self->move_left;
    }
    if ( $cmd eq 'right' ){
        $self->move_right;
    }
    if ( $cmd eq 'jump' ){
        $self->jump;
    }
}
sub jump {
    my ( $self ) = @_;
    my $current_frog = $self->current_frog;
    my $current_stone = $current_frog->stone_index;
    my $direction = $current_frog->direction;
    if ( $direction eq 'right' ){
        $self->alarm_no_jump and return if $current_stone == $self->stone_number - 1;
        my $next_frog = $self->frog_on_stone($current_stone + 1);
        if ( $next_frog->direction eq 'null' ){
            $current_frog->jump_right(1);
            return;
        }
        $self->alarm_no_jump and return if $current_stone == $self->stone_number - 2;
        my $next_next_frog = $self->frog_on_stone($current_stone + 2);
        if ( $next_next_frog->direction eq 'null' ){
            $current_frog->jump_right(2);
            return;
        }
        $self->alarm_no_jump and return;
    }
    if ( $direction eq 'left' ){
        $self->alarm_no_jump and return if $current_stone == 0;
        my $next_frog = $self->frog_on_stone($current_stone - 1);
        if ( $next_frog->direction eq 'null' ){
            $current_frog->jump_left(1);
            return;
        }
        $self->alarm_no_jump and return if $current_stone == 1;
        my $next_next_frog = $self->frog_on_stone($current_stone - 2);
        if ( $next_next_frog->direction eq 'null' ){
            $current_frog->jump_left(2);
            return;
        }
        $self->alarm_no_jump and return;
    }
}

sub move_left {
    my ( $self ) = @_;
    my $current_stone = $self->current_frog->stone_index;
    if( $current_stone == 0 ){
        return;
    }
    my $next_frog = $self->frog_on_stone($current_stone - 1);
    if ($next_frog->direction eq 'null' ) {
        if ( $current_stone == 1 ){
            return;
        }
        else{
            $next_frog = $self->frog_on_stone($current_stone - 2);
        }
    }
    $self->set_current_frog( $next_frog );
}

sub move_right {
    my ( $self ) = @_;
    my $current_stone = $self->current_frog->stone_index;
    if( $current_stone == $self->stone_number - 1 ){
        return;
    }
    my $next_frog = $self->frog_on_stone($current_stone + 1);
    if ($next_frog->direction eq 'null' ) {
        if ( $current_stone == $self->stone_number - 2 ){
            return;
        }
        else{
            $next_frog = $self->frog_on_stone($current_stone + 2);
        }
    }
    $self->set_current_frog( $next_frog );
}

sub alarm_no_jump {
    return 1;
}

sub win {
    my $self = shift;
    foreach my $stone ( 0..$self->stone_number-1 ){
        return 0 if $self->target_directions->[$stone] ne $self->frog_on_stone($stone)->direction;
    }
    return 1;
}

sub lose {
    my $self = shift;
    return 0;
}
1;
