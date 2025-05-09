ARG TAG
FROM --platform=linux/amd64 gitlab/gitlab-ce:$TAG

RUN \
	apt-get update && \
	apt-get install -y awscli jq && \
	rm -rf /var/lib/apt/lists/*

# Make sure pre-receive hooks directory structure exists, copy the hook file and make it executable
RUN mkdir -p /var/opt/gitlab/gitaly/custom_hooks/pre-receive.d
COPY block-data-files.sh /var/opt/gitlab/gitaly/custom_hooks/pre-receive.d/01-block-data-files.sh
RUN chmod +x /var/opt/gitlab/gitaly/custom_hooks/pre-receive.d/01-block-data-files.sh
RUN chown git:git /var/opt/gitlab/gitaly/custom_hooks/pre-receive.d/01-block-data-files.sh

COPY start.sh /

CMD /start.sh
