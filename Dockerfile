# ================================
# Build image
# ================================
FROM swift:6.3.3-jammy as build

WORKDIR /build

# Install build dependencies if needed
RUN apt-get update && apt-get install -y \
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

# Install runtime dependencies required by Vapor and Swift
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary and assets from build stage
COPY --from=build /build/.build/release/SWITF_DEMO_001 /app/app
# Copy public/resources if your project uses them
# COPY --from=build /build/Public /app/Public

EXPOSE 8080

ENTRYPOINT ["./app"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]