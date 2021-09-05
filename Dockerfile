FROM python:3.8-alpine

# Set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

ARG PROJECT_NAME=traveller
ARG USERNAME=traveller
ARG GROUP=$USERNAME
ARG CODE_DIR=/traveller

RUN apk update && \
        apk add sudo && \
        apk add postgresql-libs bash && \
        apk add --virtual .build-deps gcc musl-dev postgresql-dev libffi-dev binutils libc-dev curl && \
        apk add python3-dev jpeg-dev zlib-dev libjpeg && \
        apk add build-base

RUN addgroup -g 1000 -S $GROUP \
    && adduser -D --uid 1000 -S -G $USERNAME $GROUP \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && mkdir -p $CODE_DIR \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown -R $USERNAME:$GROUP $CODE_DIR

WORKDIR $CODE_DIR

# Install dependencies
COPY --chown=$USERNAME:$GROUP dev_requirements.txt requirements.txt $CODE_DIR/

RUN pip install -r dev_requirements.txt
RUN apk --purge del .build-deps

USER $USERNAME

COPY --chown=$USERNAME:$GROUP . $CODE_DIR

