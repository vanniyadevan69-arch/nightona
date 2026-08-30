// Copyright 2025 Daytona Platforms Inc.
// SPDX-License-Identifier: AGPL-3.0

package docker

import "runtime"

// hostArch is the runner binary's own architecture (arm64 or amd64), which is
// what actually matters for sandbox containers: they run on THIS machine's
// docker daemon, so they must match ITS native architecture -- not whatever
// arbitrary value happened to be hardcoded when this was only ever deployed
// on amd64 servers.
//
// This runner previously hardcoded every sandbox-container Platform
// (ContainerCreate/ContainerResize/ImagePull/registry manifest lookups/image
// builds) to "amd64" unconditionally. On an Apple Silicon host that forces
// every single sandbox through full QEMU binary emulation even though the
// upstream sandbox images (e.g. ghcr.io/nightona-co/sandbox) are published as
// genuine multi-arch manifests with a native arm64 variant available. Under
// that emulation, PTY spawn (fork+exec of the in-container shell) was
// observed to intermittently-to-persistently fail with "failed to start PTY
// session" even though the target binary genuinely exists on disk -- a real,
// reproducible failure mode of running fork/exec-heavy workloads under
// qemu-user translation, not a bug in the sandboxed image itself.
var hostArch = runtime.GOARCH

// dockerPlatformString is the "os/arch" form the Docker Engine API's
// ImagePull/ImageBuild Platform option expects.
func dockerPlatformString() string {
	return "linux/" + hostArch
}
