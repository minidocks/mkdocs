#!/bin/sh
set -e

image="${namespace:-minidocks}/mkdocs"
versions="
1;1.5.3
1-pdf;1.5.3;weasyprint;pdf
pdf;1.5.3;weasyprint;pdf
latest;1.5.3;
"

build() {
    IFS=" "
    docker buildx build $docker_opts --target="${4:-latest}" --build-arg base_image="${3:-python}" --build-arg mkdocs_version="$2" -t "$image:$1" "$(dirname $0)"
}

case "$1" in
    --versions) echo "$versions" | awk 'NF' | cut -d';' -f1;;
    '') echo "$versions" | grep -v "^$" | while read -r version; do IFS=';'; build $version; done;;
    *) args="$(echo "$versions" | grep -E "^$1(;|$)")"; if [ -n "$args" ]; then IFS=';'; build $args; else echo "Version $1 does not exist." >/dev/stderr; exit 1; fi
esac
