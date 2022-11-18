FROM ubuntu:jammy as base

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

# Install dependencies for python
RUN apt-get update && apt-get install -y --no-install-recommends gcc\
  python3 \
  python3-pip
RUN pip install pipenv

FROM base AS application-deps

# Install all python dependecies in /.venv
COPY Pipfile.lock .
COPY Pipfile .
RUN PIPENV_VENV_IN_PROJECT=1 pipenv install --deploy

FROM base AS runtime
COPY --from=application-deps /.venv /.venv
ENV PATH="/.venv/bin:$PATH"

COPY main.py main.py
EXPOSE 10000/tcp

RUN mkdir -p "/opt/newrelic"
COPY newrelic.ini /opt/newrelic/newrelic.ini
ENV NEW_RELIC_CONFIG_FILE="/opt/newrelic/newrelic.ini"


ENTRYPOINT ["newrelic-admin", "run-program", "python", "main.py"]