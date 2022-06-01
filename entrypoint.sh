#!/bin/bash

set -ex

while getopts "a:b:c:" o; do
  case "${o}" in
    a)
      export policy_repository=${OPTARG}
    ;;
    b)
      export policy_dir=${OPTARG}
    ;;
    c)
      export namespaces=${OPTARG}
    ;;
  esac
done

TRIVY_ARGS="-q conf -f sarif"
if [ $policy_repository ]; then
  conftest pull $policy_repository -p trivy-policies
fi

if [ $policy_dir ]; then
  TRIVY_ARGS="$TRIVY_ARGS --policy trivy-policies/$policy_dir"
fi

if [ $namespaces ]; then
  TRIVY_ARGS="$TRIVY_ARGS --namespaces $namespaces"
fi

trivy $TRIVY_ARGS . \
  | jq '.runs[].results[] | "\(.level[0:1]):\(.locations[].physicalLocation.artifactLocation.uri):\(.locations[].physicalLocation.region.endLine) \(.message.text)"' \
  | sed "s/\\\\n/<br>/g" \
  | reviewdog -efm="\"%t:%f:%l %m\"" --diff="git diff ${GITHUB_REF}" -reporter=github-pr-review
