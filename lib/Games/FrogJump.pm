=head1 NAME

Games::FrogJump - An ASCII game for fun

=head1 SYNOPIS

 use Games::FrogJump;
 Games::FrogJump->new->run;

=head1 DESCRIPTION

This module is an ASCII game , It runs at command-line. Control the frogs jump to each side.

Play the game with command:

  frogjump

=head1 AUTHOR

tadegenban <tadegenban@gmail.com>

=cut

package Games::FrogJump;
use 5.012;
use Moo;

our $VERSION = '0.08';

use Time::HiRes;

use constant {
	FRAME_TIME => 1/4,
};

use lib '../../lib';
use Games::FrogJump::Game;
use Games::FrogJump::Frog;
use Games::FrogJump::Input;


sub run {
    my $self = shift;
    my $game;
    my $restart;
    my $quit;

    while (!$quit) {

        if ( !$game ) {
            $game = Games::FrogJump::Game->new();
        }
        $game->init;
      RUN: $game->draw;
		my $time = Time::HiRes::time;
      PLAY: while ( 1 ) {
          while ( defined(my $key = Games::FrogJump::Input::read_key) ) {
              my $cmd = Games::FrogJump::Input::key_to_cmd($key);
              if ( $cmd eq 'quit' ){
                  $quit = 1;
                  last PLAY;
              }
              if ( $cmd eq 'restart' ){
                  $restart = 1;
                  last PLAY;
              }
              if ( $cmd ) {
                  $game->act($cmd);
              }
          }
          $game->draw;
          my $new_time = Time::HiRes::time;
          my $delta_time = $new_time - $time;
          my $delay = FRAME_TIME - $delta_time;
          $time = $new_time;
          if ($delay > 0) {
              Time::HiRes::sleep($delay);
              $time += $delay;
          }
          if ( $game->win || $game->lose ){
              last PLAY;
          }
      }
        if ( $game->win ){
            $game->draw_win;
            $quit = 1;
        }
    }
    $game->draw_quit;
}
1;

