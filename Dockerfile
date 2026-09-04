# ================================
# Build image
# ================================
FROM swift:6.3.3-noble as build

WORKDIR /build

# Bypass GPG signature check if network environment strips keys
RUN apt-get -o Acquire::Check-Valid-Until=false -o Acquire::AllowInsecureRepositories=true update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY Package.swift Package.resolved* ./
RUN swift package resolve

# Copy source code
COPY . .

# Build release executable
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

COPY --from=build /build/.build/release/SWITF_DEMO_001 /app/app

EXPOSE 8080

ENTRYPOINT ["./app"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]