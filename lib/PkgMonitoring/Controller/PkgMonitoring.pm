package PkgMonitoring::Controller::PkgMonitoring;
use Mojo::Base 'Mojolicious::Controller';

use AnyEvent::Filesys::Notify;


sub index {
   my $self = shift;

   $self->render();
}

### sub events {
###    my $self = shift;
###
###    # Emit "dice" event every second
###    $self->res->headers->content_type('text/event-stream');
###
###    my $id = Mojo::IOLoop->recurring(1 => sub {
###       my $pips = int(rand 6) + 1;
###       $self->write("event:dice\ndata: $pips\n\n");
###    });
###
###    $self->on(finish => sub {
###       Mojo::IOLoop->remove($id);
###    });
### }

sub events {
   my $self = shift;

   # Emit "dice" event every second
   $self->res->headers->content_type('text/event-stream');

   my $cv = AE::cv;

   my $notifier = AnyEvent::Filesys::Notify->new(
      dirs     => [ '/root' ],
#      dirs     => [ '/var/run' ],
#      interval => 2.0,             # Optional depending on underlying watcher
      filter   => qr#^/root/prueba\.txt$#,
#      filter   => qr#^/var/run/zypp\.pid$#,
      cb       => sub {
         my (@events) = @_;

         my $events_string = 'Events: ';
         for my $event (@events) {
            $events_string .= $event->path.':';
            if ($event->is_created) {
               $events_string .= 'created';
            }
            elsif ($event->is_modified) {
               $events_string .= 'modified';
            }
            elsif ($event->is_deleted) {
               $events_string .= 'deleted';
            }
            else {
               $events_string .= 'unknown';
            }
            $events_string .= ', ';
         }
         $events_string =~ s/, $//;
         $self->app->log->debug("events cb entered! $events_string");
         $cv->send($events_string);
      },
      parse_events => 1,  # Improves efficiency on certain platforms
   );

   my $result = $cv->recv;

   $self->write("event:dice\ndata: $result\n\n");
}

1;
