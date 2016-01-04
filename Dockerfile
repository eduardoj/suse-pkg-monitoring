FROM opensuse:latest

# Neccesary packages
RUN zypper --non-interactive install cpanm make
# Optional packages
RUN zypper --non-interactive install curl git less vim wget


# Prevent cpan prompting for initial configuration
ENV cpan_config_file /root/.cpan/CPAN/MyConfig.pm
COPY files$cpan_config_file $cpan_config_file

RUN cpan Mojolicious


# Mojolicious application
ENV mojo_dir /var/virtual/pkg_monitoring/

ADD t script public lib templates $mojo_dir

EXPOSE 8080

WORKDIR $mojo_dir

CMD hypnotoad script/pkg_monitoring
