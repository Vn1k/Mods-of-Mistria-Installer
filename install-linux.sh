#!/usr/bin/env bash
# Native build + install on Linux (x86_64 or aarch64), no FEX/emulation needed.
# Fedora deps: sudo dnf install -y dotnet-sdk-10.0 cargo git
# Usage: ./install-linux.sh [install dir, default ~/.local/opt/momi]
set -euo pipefail
cd "$(dirname "$0")"

case "$(uname -m)" in
    aarch64) rid=linux-arm64 sfx= ;;
    x86_64)  rid=linux-x64 sfx=-linux ;;
    *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac
out="${1:-$HOME/.local/opt/momi}"

cargo build --release --manifest-path tools/checker/Cargo.toml --bin momi-gml-check
install -D tools/checker/target/release/momi-gml-check "tools/checker/dist/$rid/momi-gml-check"

# Framework-dependent, plain folder: uses the distro's .NET runtime
for project in ModsOfMistriaGUI ModsOfMistriaCommandLine; do
    dotnet publish "$project" -c Release -r "$rid" -o "$out" --nologo -v q \
        -p:SelfContained=false -p:PublishSingleFile=false -p:PublishReadyToRun=false
done
chmod +x "$out/momi-gml-check"

mkdir -p "$HOME/.local/bin"
ln -sf "$out/ModsOfMistriaInstaller$sfx" "$HOME/.local/bin/momi"
ln -sf "$out/ModsOfMistriaInstaller-cli$sfx" "$HOME/.local/bin/momi-cli"
echo "Installed: momi (GUI), momi-cli (version $("$HOME/.local/bin/momi-cli" --version))"
