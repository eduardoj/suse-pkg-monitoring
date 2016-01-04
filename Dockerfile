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
ENV mojo_app_name pkg_monitoring
ENV mojo_dir /var/virtual/$mojo_app_name

RUN mkdir -p $mojo_dir/log

ADD $mojo_app_name.conf $mojo_dir/

ADD lib $mojo_dir/lib
ADD public $mojo_dir/public
ADD script $mojo_dir/script
ADD t $mojo_dir/t
ADD templates $mojo_dir/templates

WORKDIR $mojo_dir

EXPOSE 8080

CMD hypnotoad -f script/$mojo_app_name
#CMD MOJO_MODE=development hypnotoad -f script/$mojo_app_name
