#!/bin/bash

set -euo pipefail

exec bash "$(dirname "$0")/build-computer-use.sh" amd64
