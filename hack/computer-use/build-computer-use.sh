#!/bin/bash

set -euo pipefail

arch="${1:?usage: build-computer-use.sh <amd64|arm64>}"
case "$arch" in
    amd64|arm64) ;;
    *)
        echo "Unsupported computer-use architecture: $arch" >&2
        exit 2
        ;;
esac

if [ -n "${SKIP_COMPUTER_USE_BUILD:-}" ]; then
    echo "Skipping computer-use ${arch} build"
    exit 0
fi

mkdir -p dist/libs

native_arch="$(uname -m)"
if { [ "$arch" = "amd64" ] && [ "$native_arch" = "x86_64" ]; } ||
   { [ "$arch" = "arm64" ] && [ "$native_arch" = "aarch64" ]; }; then
    echo "Building computer-use for ${arch} natively..."
    (
        cd libs/computer-use
        CGO_ENABLED=1 GOOS=linux GOARCH="$arch" \
            GONOSUMDB=github.com/nightona-co/nightona \
            go build -ldflags="-w -s" -o "../../dist/libs/computer-use-${arch}" main.go
    )
else
    echo "Building computer-use for ${arch} with Docker..."
    image="computer-use-${arch}:build"
    docker build \
        --platform "linux/${arch}" \
        --build-arg "TARGETARCH=${arch}" \
        -t "$image" \
        -f hack/computer-use/Dockerfile \
        .
    docker run --rm \
        --platform "linux/${arch}" \
        -v "$(pwd)/dist:/dist" \
        "$image"
fi

test -s "dist/libs/computer-use-${arch}"
echo "Built dist/libs/computer-use-${arch}"
