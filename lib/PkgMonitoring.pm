package PkgMonitoring;
use Mojo::Base 'Mojolicious';

use Mojolicious::Plugin::Config;


sub startup {
  my $self = shift;

  $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/')->to('example#welcome');
}

1;
