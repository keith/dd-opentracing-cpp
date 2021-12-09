#!/bin/sh

usage() {
    cat <<'END_USAGE'
Download the most recent github release of the "cppcodec" third party library
and install its headers, license, and a generated readme file into the
3rd_party/ directory of this repository.

Options:

  --help
  -h
    Print this message.
END_USAGE
}

# Exit if any non-conditional command returns a nonzero exit status.
set -e

# Parse command line options.
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit ;;
    *)
      >&2 usage
      >&2 printf "\nUnknown option: %s\n" "$1"
      exit 1
  esac
  shift
done

# Download and untar the release.
workspace=$(mktemp -d)
latest_url='https://api.github.com/repos/tplgy/cppcodec/releases/latest'
tarball_url=$(curl --silent "$latest_url" | jq --raw-output .tarball_url)
wget --quiet --output-document="$workspace/release.tar.gz" "$tarball_url"
mkdir "$workspace/release"
tar zxf "$workspace/release.tar.gz" --directory="$workspace/release" --strip=1

mv "$workspace/release/LICENSE" "$workspace/release/cppcodec"
>"$workspace/release/cppcodec/README.md" cat <<END_README
These are the header files from following [github release][1] of
[tplgy/cppcodec][2].

The library is used to encode and decode base64.

This readme file was generated by [scripts/pull_cppcodec.sh][3].

[1]: $tarball_url
[2]: https://github.com/tplgy/cppcodec
[3]: ../../../scripts/pull_cppcodec.sh
END_README

# Get to the root of the repository.
cd "$(dirname "$0")"
cd "$(git rev-parse --show-toplevel)"

# Install under 3rd_party/
rm -rf 3rd_party/include/cppcodec
mv "$workspace/release/cppcodec" 3rd_party/include

rm -r "$workspace"