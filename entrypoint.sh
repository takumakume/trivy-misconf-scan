#!/bin/bash

set -e

while getopts "a:b:" o; do
  case "${o}" in
    a)
      export policy=${OPTARG}
    ;;
    b)
      export namespaces=${OPTARG}
    ;;
  esac
done

TRIVY_ARGS="-q conf -f sarif"
if [ $policy ]; then
  conftest pull $policy -p policy
  TRIVY_ARGS="$TRIVY_ARGS --policy policy"
fi

if [ $namespaces ]; then
  TRIVY_ARGS="$TRIVY_ARGS --namespaces $namespaces"
fi

trivy $TRIVY_ARGS . \
  | jq '.runs[].results[] | "\(.level[0:1]):\(.locations[].physicalLocation.artifactLocation.uri):\(.locations[].physicalLocation.region.endLine) \(.message.text)"' \
  | sed "s/\\\\n/<br>/g" \
  | reviewdog -efm="\"%t:%f:%l %m\"" --diff="git diff ${GITHUB_REF}" -reporter=github-pr-review
