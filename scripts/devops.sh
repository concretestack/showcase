#!/usr/bin/env bash
# Copyright (c) 2022 Chassi, Inc. All rights reserved.

# Builds, packages, publishes and cleans spinnaker packages.

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail

VERSION="${SHOWCASE_VERSION:-}"

# Publishing prefix for Aptly
DEBIAN_REPO="examples"
INFERRED_HOME=$( dirname "$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )")
REPOSITORY_HOME="${PROJECT_ROOT:-${INFERRED_HOME}}"
# Scratch dir where all our generated outputs are kepts
OUTPUT_DIR="${REPOSITORY_HOME}/outputs"
# Where are debian packages copied to for uploading by github artifacts
DEBS_OUTPUT="${OUTPUT_DIR}/debs"
# Directory hosting aggregated artifacts to be uploaded via Aptly
APTLY_UPLOADS="${REPOSITORY_HOME}/aptly"
# Specify aptly storage configuration to use to host our debian repo
APTLY_STORAGE="s3:service-delivery:${DEBIAN_REPO}/"

echo "environment variables currently set:"
env

function parse_default_arguments() {
    if [[ ! "$#" -eq 3 ]] || [[ -z "$3" ]];
    then
      echo -e "\033[31m[ERROR] Insufficient Arguments.\033[0m"
      echo -e "\033[31m[ERROR] ===> specify the gradle task target and application \033[0m"
      echo -e ""
      echo -e "Usage:"
      echo -e "devops.sh [argument] <target> <application>"
      exit 1
    fi

    export GRADLE_TARGET="${2}"
    export APPLICATION="${3}"
}

function publish_v2() {
  echo "Aggregating debian packages"
  mkdir -p "${APTLY_UPLOADS}"
  # shellcheck disable=SC2038
  find "${REPOSITORY_HOME}/" -type f -name "*.deb" | xargs -I{} cp {} "${APTLY_UPLOADS}/"
  echo "publishing generated packages to chassi debian repository"
  aptly repo create -distribution=jammy -component=main "${DEBIAN_REPO}"
  aptly repo add "${DEBIAN_REPO}" "${APTLY_UPLOADS}"
  aptly repo show -with-packages "${DEBIAN_REPO}"
  aptly snapshot create "${DEBIAN_REPO}-${VERSION}" from repo "${DEBIAN_REPO}"
  aptly snapshot list
  aptly publish snapshot -architectures="all" "${DEBIAN_REPO}-${VERSION}" "${APTLY_STORAGE}"
}

case "${1:-}" in
  --build|-b)
    parse_default_arguments "$@"
    build
    ;;
  --package|-j)
    parse_default_arguments "$@"
    package
    ;;
  --publish|-p)
    publish_v2
    ;;
  *)
    echo "executing default action (nothing)"
esac