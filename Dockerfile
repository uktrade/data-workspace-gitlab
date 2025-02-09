FROM --platform=linux/amd64 gitlab/gitlab-ce:13.12.15-ce.0

RUN \
	apt-get update && \
	apt-get install -y awscli jq && \
	rm -rf /var/lib/apt/lists/*

COPY start.sh /

CMD /start.sh
