# LibreOffice Document Converter v.0.1
# Optimized for batch conversion (DOCX to PDF)
#
# @author Sidney Curron <sidney.curron@oligos.fr>
# @version 0.1
# @date 2026
#
# @copyright Oligos - Magellan
#
# @description Docker image for headless document conversion using LibreOffice

# Maybe, maybe, ...!
# Using Alpine or debian-slim may be your prefered choice here. 
# You would want to check the size of this image.
FROM debian:bookworm-slim

# Build arguments for version pinning (optional)
ARG DEBIAN_FRONTEND=noninteractive
ARG LO_VERSION=""
ARG LC_ALL=C.UTF-8

# Set environment variables
ENV DEBIAN_FRONTEND=${DEBIAN_FRONTEND} \
    HOME=/tmp \
    LC_ALL=C.UTF-8

# Install only headless LibreOffice components in a single layer
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libreoffice-writer-nogui \
        libreoffice-calc-nogui \
        libreoffice-impress-nogui \
        fonts-liberation2 \
        fonts-dejavu-core \
        ca-certificates \
    # Vi editor is normally presents in every distro.
    # I used to play with Vim  (or emacs. Careful, the size of this last one can make your image bigger)
        vim \
    #    emacs \
    # Clean up in the same layer to reduce image size
    # I don't recommend to remove theses followings lines, It's up to you!
    && apt-get clean \
    && rm -rf \
        /usr/share/doc/* \
        /usr/share/man/* \
        /usr/share/locale/* \
        /usr/lib/libreoffice/share/gallery/* \
        /usr/lib/libreoffice/share/template/* \
        /var/cache/apt/* \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \

    # Create non-root user for security
    # Again, I do not recommend to remove this line too.
    && groupadd -r converter && useradd -r -g converter -d /tmp -s /bin/bash converter

WORKDIR /workspace

# Copy and setup conversion script
COPY --chown=converter:converter convert.sh /usr/local/bin/convert
RUN chmod +x /usr/local/bin/convert

# Switch to non-root user
# We need to prevent root-privilege for the user. (even if it's docker)
USER converter

ENTRYPOINT ["/usr/local/bin/convert"]
