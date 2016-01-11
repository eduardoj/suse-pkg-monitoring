package PkgMonitoring::Controller::PkgMonitoring;
use Mojo::Base 'Mojolicious::Controller';

use AnyEvent::Filesys::Notify;
use EV;
use Mojo::IOLoop;
use Mojo::JSON qw(encode_json);


my @cons = ();

my %zypper_status = ();

my $notifier = AnyEvent::Filesys::Notify->new(
   dirs     => [ '/var/run' ],
#   interval => 2.0,    # Optional depending on underlying watcher
   filter   => qr#/run/zypp\.pid$#,    # Could be /var/run/zypp.pid or /run/zypp.pid
   cb       => sub {
      my (@events) = @_;

      my $events_string = 'Events: ';
      for my $event (@events) {
         $events_string .= $event->path.':';

         my $zypp_pid;
         if ($event->is_created) {
            $events_string .= 'created';
         }
         elsif ($event->is_modified) {
            $events_string .= 'modified';

            # Read file content
            my $filename = '/var/run/zypp.pid';
            open FH, '<', $filename
               or die "error opening $filename: $!";
            $zypp_pid = do { local $/; <FH> };
            close FH;

            chomp $zypp_pid;
            $events_string .= ', file content: '.$zypp_pid;

            if ($zypp_pid) {
               $zypper_status{status} = 'Running';
               $zypper_status{pid} = $zypp_pid;
               my $command = "ps -o cmd= -p $zypp_pid";
               my $cmd_string = `$command`;
               chomp $cmd_string;
               $zypper_status{cmd} = $cmd_string;
            }
            else {
               $zypper_status{status} = 'Not running';
               $zypper_status{last_pid} = $zypper_status{pid};
               delete $zypper_status{pid};
               delete $zypper_status{cmd};
            }
         }
         elsif ($event->is_deleted) {
            $events_string .= 'deleted';
         }
         else {
            $events_string .= 'unknown';
            $zypper_status{status} = 'Unknown';
         }
         $events_string .= ', ';
      }
      $events_string =~ s/, $//;

      foreach my $con (@cons) {
         #$con->app->log->debug("events cb entered! con: $con, worker: $$, events_string: $events_string");
         #$con->write("event:dice\ndata: $events_string\n\n");
         my $json = encode_json(\%zypper_status);
         $con->write("event:dice\ndata: $json\n\n");
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

      #print STDERR "finish, before deleting, \$self: '$self'\n";
      #print STDERR "\@cons: '".join ("', '", @cons)."'\n";

      my $index = 0;
      foreach my $value (@cons) {
         if ($value eq $self) {
            splice @cons, $index, 1;
            last;
         }
         $index ++;
      }

      #print STDERR "\@cons: '".join ("', '", @cons)."'\n";
   });
}

1;
