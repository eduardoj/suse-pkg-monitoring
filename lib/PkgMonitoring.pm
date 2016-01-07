package PkgMonitoring;
use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::Config;


sub startup {
   my $self = shift;

   $self->secrets(['My very secret passphrase for pkg-monitoring.']);

   $self->plugin('Config');

   # Documentation browser under "/perldoc"
   $self->plugin('PODRenderer');

   # Router
   my $r = $self->routes;

   # Normal route to controller
# TODO: remove controller 'example'
#  $r->get('/')->to('example#welcome');
   $r->get('/')->to('pkg_monitoring#index')->name('index');
   $r->get('/events')->to('pkg_monitoring#events')->name('events');
}

1;
