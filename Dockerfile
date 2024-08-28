FROM debian:12-slim


# Update
RUN apt-get update


# Install packages
RUN apt-get -yq install rsync openssh-client


# Label
LABEL "com.github.actions.name"="rsync deployments"
LABEL "com.github.actions.description"="Quick and simple method of deploying code to a webserver via rsync over ssh"
LABEL "com.github.actions.icon"="truck"
LABEL "com.github.actions.color"="yellow"

LABEL "repository"="http://github.com/contention/rsync-deployments"
LABEL "homepage"="https://github.com/contention/rsync-deployments"
LABEL "maintainer"="Contention <hello@contention.agency>"


# Copy entrypoint
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
