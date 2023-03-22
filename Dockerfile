FROM alpine:latest

RUN apk --no-cache add jq git bash

# Install Trivy
COPY --from=aquasec/trivy:latest /usr/local/bin/trivy /usr/local/bin/trivy

# Install Conftest
COPY --from=openpolicyagent/conftest:latest /conftest /usr/local/bin/conftest

# Install ReviewDog
RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
