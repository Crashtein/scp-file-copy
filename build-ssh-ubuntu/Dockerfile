FROM ubuntu:22.04

# update packages, install openssh-server and remove cache
RUN apt-get update && \
    apt-get install -y openssh-server cron nano ansible && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# make dirs for sshd and for .ssh keys
RUN mkdir -p /var/run/sshd /root/.ssh

# set default password for root "root"
RUN echo 'root:root' | chpasswd

COPY ./demo-keys/ssh_keys/ /root/.ssh/

# set permissions for authorized keys folders
RUN chmod 600 -R /root/.ssh && \
    chmod 700 /root/.ssh

COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]