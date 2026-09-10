# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.21
ARG JANET_VERSION=1.42.0
ARG USER=app
ARG UID=1101
ARG GID=1101

# ---------------------------------------------------------------------------
# Builder
#
# This stage contains the complete build environment:
#   - Janet
#   - JPM
#   - C toolchain
#   - native dependencies
#   - application dependencies
#   - application source
#
# jpm build produces the actual application executable.
# ---------------------------------------------------------------------------
FROM alpine:${ALPINE_VERSION} AS builder

ARG JANET_VERSION

RUN apk add --no-cache \
    build-base \
    ca-certificates \
    curl \
    curl-dev \
    git \
    sqlite-dev

# Build and install Janet.
RUN git clone --depth 1 --branch "v${JANET_VERSION}" \
      https://github.com/janet-lang/janet.git /tmp/janet \
    && make -C /tmp/janet all test install \
    && rm -rf /tmp/janet

# Install JPM.
RUN git clone --depth=1 \
      https://github.com/janet-lang/jpm.git /tmp/jpm \
    && cd /tmp/jpm \
    && janet bootstrap.janet \
    && rm -rf /tmp/jpm

ENV JANET_PATH=/usr/local/lib/janet

# Install Joy and its native dependencies while the compiler is available.
RUN jpm install joy

WORKDIR /var/app

# Copy dependency manifest first so dependency installation can be cached
# independently of application source changes.
COPY project.janet ./
# COPY jpm.lock ./

RUN jpm deps

# Now copy the application source.
COPY . ./

# Build the actual application, including any native C extensions.
RUN jpm build


# ---------------------------------------------------------------------------
# Runtime
#
# Only Janet, runtime shared libraries, and the compiled application are
# included here. No compiler, git, JPM, headers, or application source.
# ---------------------------------------------------------------------------
FROM alpine:${ALPINE_VERSION} AS runtime

ARG USER
ARG UID
ARG GID

RUN apk add --no-cache \
    ca-certificates \
    libcurl \
    libgcc \
    libstdc++ \
    sqlite-libs

# Janet runtime.
COPY --from=builder /usr/local/bin/janet /usr/local/bin/janet
COPY --from=builder /usr/local/lib/janet /usr/local/lib/janet

# Compiled application artifact.
COPY --from=builder /var/app/build/app /var/app/build/app

# static files my app will serve
COPY ./public /var/app/public

# Run as an unprivileged user.
RUN addgroup -g "${GID}" -S "${USER}" \
    && adduser -u "${UID}" -S "${USER}" -G "${USER}" \
    && chown -R "${USER}:${USER}" /var/app

WORKDIR /var/app

USER ${USER}

RUN janet --version

EXPOSE 9001

CMD ["./build/app"]
