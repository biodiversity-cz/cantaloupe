FROM debian:bookworm@sha256:321341744acb788e251ebd374aecc1a42d60ce65da7bd4ee9207ff6be6686a62

ARG CANTALOUPE_VERSION

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick \
    libopenjp2-tools ffmpeg unzip default-jre-headless && \
    apt-get -qqy autoremove && apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/* \

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && unzip Cantaloupe-$CANTALOUPE_VERSION.zip -d cantaloupe \
    && rm Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mv /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.jar /cantaloupe/cantaloupe.jar \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/


USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample -jar /cantaloupe/cantaloupe.jar"]
