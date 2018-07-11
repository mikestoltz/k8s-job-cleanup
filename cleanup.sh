#!/bin/sh

# get variables
NAMESPACE="${NAMESPACE}"
SELECTORS="${SELECTORS}"
CLEANUP_OFFSET="${CLEANUP_OFFSET}"
DRY_RUN="${DRY_RUN}"

# set namespace or all namespaces
[[ $NAMESPACE == "" ]] && NAMESPACE_FLAG="--all-namespaces" || NAMESPACE_FLAG="-n"
# set selectors or all jobs
[[ $SELECTORS == "" ]] && SELECTOR_FLAG="" || SELECTOR_FLAG="-l"
# set offset or one day
[[ $CLEANUP_OFFSET == "" ]] && OFFSET="86400" || OFFSET="$CLEANUP_OFFSET"

DATE=$(date -u -d @$(( $(date +"%s") - $OFFSET)) +%Y-%m-%dT%H:%M:%S)

if [[ $DRY_RUN == "true" ]]; then
    echo "DRY_RUN enabled - no jobs will actually be deleted."
fi

set +e

DATE="\"$DATE\""
JSONPATH="jsonpath={.items[?(@.metadata.creationTimestamp<$DATE)].metadata.name}"

for job_name in $(kubectl get jobs $SELECTOR_FLAG "$SELECTORS" -o "$JSONPATH" $NAMESPACE_FLAG $NAMESPACE); do
    if [[ $DRY_RUN == "true" ]]; then
        echo $job_name
    else
        kubectl delete job $job_name $NAMESPACE_FLAG $NAMESPACE
    fi
done

set -e
