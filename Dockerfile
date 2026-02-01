FROM debian:trixie@sha256:5cf544fad978371b3df255b61e209b373583cb88b733475c86e49faa15ac2104

ARG CANTALOUPE_VERSION

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -qy && apt-get dist-upgrade -qy && \
    apt-get install -qy --no-install-recommends curl imagemagick \
    libopenjp2-7 ffmpeg unzip default-jre-headless libturbojpeg-java && \
    apt-get -qqy autoremove && apt-get -qqy autoclean && \
    rm -rf /var/lib/apt/lists/* /var/lib/log/* /tmp/* /var/tmp/*

# Run non privileged
RUN useradd -r -u 1000 -s /bin/false cantaloupe
RUN mkdir -p /iiif_cache && chown -R cantaloupe:cantaloupe /iiif_cache

WORKDIR /

# Get and unpack Cantaloupe release archive
RUN curl --silent --fail -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
    && unzip Cantaloupe-$CANTALOUPE_VERSION.zip  \
    && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
    && rm Cantaloupe-$CANTALOUPE_VERSION.zip \
    && mv /cantaloupe/cantaloupe-$CANTALOUPE_VERSION.jar /cantaloupe/cantaloupe.jar \
    && mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
    && chown -R cantaloupe /cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    && cp -rs /cantaloupe/deps/Linux-x86-64/* /usr/


USER cantaloupe

ENTRYPOINT ["java"]
CMD ["-Xms2g", "-Xmx4g", "-Dcantaloupe.config=/cantaloupe/cantaloupe.properties.sample", "-jar", "/cantaloupe/cantaloupe.jar"]

