package PkgMonitoring::Controller::PkgMonitoring;
use Mojo::Base 'Mojolicious::Controller';

use AnyEvent::Filesys::Notify;
use EV;
use Mojo::IOLoop;


my @cons = ();

my $notifier = AnyEvent::Filesys::Notify->new(
   dirs     => [ '/root' ],
#   dirs     => [ '/var/run' ],
#   interval => 2.0,             # Optional depending on underlying watcher
   filter   => qr#^/root/prueba\.txt$#,
#   filter   => qr#^/var/run/zypp\.pid$#,
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

            # Read file content
            my $filename = '/root/prueba.txt';
            open FH, '<', $filename
               or die "error opening $filename: $!";
            my $data = do { local $/; <FH> };
            close FH;

            chomp $data;
            $events_string .= ', file content: '.$data;
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

      foreach my $con (@cons) {
#         $con->app->log->debug("events cb entered! con: $con, worker: $$, events_string: $events_string");
         $con->write("event:dice\ndata: $events_string\n\n");
      }
   },
#   parse_events => 1,  # Improves efficiency on certain platforms
);


sub index {
   my $self = shift;

   $self->render();
}


sub events {
   my $self = shift;

   # Increase inactivity timeout for connection
   Mojo::IOLoop->stream($self->tx->connection)->timeout(3600);

   $self->res->headers->content_type('text/event-stream');

   # Push $self to the list of connections
   push @cons, $self;

   # When the connection closes
   $self->on(finish => sub {
      # Remove $self from @cons

#      print STDERR "finish, before deleting, \$self: '$self'\n";
#      print STDERR "\@cons: '".join ("', '", @cons)."'\n";

      my $index = 0;
      foreach my $value (@cons) {
         if ($value eq $self) {
            splice @cons, $index, 1;
            last;
         }
         $index ++;
      }

#      print STDERR "\@cons: '".join ("', '", @cons)."'\n";
   });
}

1;
