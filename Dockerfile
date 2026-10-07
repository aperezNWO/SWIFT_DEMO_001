# ================================
# Build image
# ================================
FROM swift:6.3.3-noble AS build
WORKDIR /build

# Copy dependency manifests first to leverage Docker layer caching
COPY Package.swift Package.resolved* ./
RUN swift package resolve

# Copy the rest of the source code
COPY . .

# Use BuildKit cache mounts to retain compiled objects between builds
RUN --mount=type=cache,target=/build/.build \
    --mount=type=cache,target=/root/.swiftpm \
    swift build -c release --static-swift-stdlib && \
    cp .build/release/SWITF_DEMO_001 /tmp/app

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
COPY --from=build /tmp/app /app/app

EXPOSE 8080
ENTRYPOINT ["./app"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]