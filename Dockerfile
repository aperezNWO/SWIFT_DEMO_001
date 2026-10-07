# ================================
# Build image
# ================================
FROM swift:6.3.3-noble AS build

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY Package.swift Package.resolved* ./
RUN swift package resolve

COPY . .
RUN swift build -c release --static-swift-stdlib

# ================================
# Production image
# ================================
FROM ubuntu:24.04

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy the statically-linked binary from the build stage
COPY --from=build /build/.build/release/SWITF_DEMO_001 /app/app

EXPOSE 8080

ENTRYPOINT ["./app"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]