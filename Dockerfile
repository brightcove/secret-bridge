FROM python:3-alpine

LABEL maintainer="labs@duo.com"

#####################
# IMG PREP
#####################
RUN apk add git make bash grep
WORKDIR /usr/src/app

#####################
# INSTALL REQUIREMENTS
#####################
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# setup shush
RUN curl -sL -o /usr/local/bin/shush \
https://github.com/realestate-com-au/shush/releases/download/v1.3.0/shush_linux_amd64 \
  && chmod +x /usr/local/bin/shush

# DETECTORS
WORKDIR /usr/src/secret-providers

# git-secrets
RUN git clone https://github.com/awslabs/git-secrets.git
WORKDIR /usr/src/secret-providers/git-secrets
RUN make install

WORKDIR /usr/src/app

# detect-secrets
RUN pip install detect-secrets
# trufflehog
RUN pip install trufflehog

#####################
# RUN APP
#####################
# decrypt the config maps with KMS keys
ENTRYPOINT ["/usr/local/bin/shush", "--region=us-east-1", "exec", "--"]

# start app
CMD ["python", "main.py", "poll"]
