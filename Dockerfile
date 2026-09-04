# ==============================================================================
# Build Stage
# ==============================================================================
FROM swift:6.3.3-jammy AS build

WORKDIR /app

# Copy dependency manifest files first for layer caching
COPY Package.swift Package.resolved ./
RUN swift package resolve

# Copy the rest of the source code
COPY . .

# Build the release executable
RUN swift build -c release --static-swift-stdlib

# ==============================================================================
# Run Stage
# ==============================================================================
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    libatomic1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy built binary from the build stage
COPY --from=build /app/.build/release/SWIFT_DEMO_001 /app/app

# Expose port and set entrypoint
EXPOSE 8080
ENTRYPOINT ["./app", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]