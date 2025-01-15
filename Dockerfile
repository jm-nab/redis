# Use the official Redis Stack Server image as the base image
FROM redis/redis-stack-server:7.4.0-v2

LABEL maintainer="Opstree Solutions"

ARG TARGETARCH

LABEL version=1.0 \
      arch=$TARGETARCH \
      description="A production grade performance tuned Redis Stack Docker image created by Opstree Solutions"

# Copy custom Redis configuration files into the image
COPY redis.conf /etc/redis/redis.conf
COPY redis-stack.conf /etc/redis/redis-stack.conf
COPY redis-stack-service.conf /etc/redis/redis-stack-service.conf

# Copy custom scripts
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY setupMasterSlave.sh /usr/bin/setupMasterSlave.sh
COPY healthcheck.sh /usr/bin/healthcheck.sh

# Set permissions and create necessary directories for Redis and application
RUN chown -R 1000:0 /etc/redis && \
    chmod -R g+rw /etc/redis && \
    mkdir -p /data && \
    chown -R 1000:0 /data && \
    chmod -R g+rw /data && \
    mkdir -p /node-conf && \
    chown -R 1000:0 /node-conf && \
    chmod -R g+rw /node-conf && \
    chmod -R g+rw /var/run

# Define volumes for persistence
VOLUME ["/data"]
VOLUME ["/node-conf"]

# Expose Redis default port
EXPOSE 6379

# Create a non-root user for running Redis (Debian/Ubuntu-based systems use adduser/group)
RUN addgroup --system redis && adduser --system --ingroup redis --uid 1000 redis && \
    apt-get update && apt-get install -y bash && \
    rm -rf /var/lib/apt/lists/*

# Set the entrypoint to your custom script
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Use redis-stack-server as the default command
CMD ["/usr/bin/redis-stack-server"]
