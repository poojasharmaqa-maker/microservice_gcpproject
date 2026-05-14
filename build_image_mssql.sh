#!/bin/bash
FOLDER=gcp-cloud-new
STREAMING_REPO_NAME=gcp-streaming-new
BASE_REPO_NAME=gcp-base

cur_branch=$(git rev-parse --abbrev-ref HEAD)
cur_date=$(TZ=America/Chicago date +%Y-%m-%d-%H-%M-%S)
cur_sha1=$(git rev-parse --short HEAD)

if [ -z "$1" ]
then
        echo "No parameters supplied. Using standard tag name"
else
        OPT_PARAM="-"$1
fi

if [ ${cur_branch} == "master" ]
then
        VERSION=${cur_date}-${cur_sha1}-master
        PROJECT_ID="svc-equ-prd"
        echo "building PRODUCTION IMAGE"
        echo "${STREAMING_REPO_NAME}:${VERSION}"
else
        VERSION=${cur_date}-${cur_sha1}${OPT_PARAM}
        PROJECT_ID="svc-equ-pii-sys"
        echo "building SYSTEST IMAGE"
        echo "${STREAMING_REPO_NAME}:${VERSION}"
fi

docker build --build-arg PROJECT_ID=${PROJECT_ID} --build-arg FOLDER=${FOLDER} --build-arg BASE_REPO_NAME=${BASE_REPO_NAME} \
-f Dockerfile-mssql -t us-east4-docker.pkg.dev/${PROJECT_ID}/${FOLDER}/${STREAMING_REPO_NAME}:${VERSION} .
if [[ $? -ne 0 ]]
then
        echo "Unable to build docker image"
        exit 1
fi
docker tag us-east4-docker.pkg.dev/${PROJECT_ID}/${FOLDER}/${STREAMING_REPO_NAME}:${VERSION}
docker push us-east4-docker.pkg.dev/${PROJECT_ID}/${FOLDER}/${STREAMING_REPO_NAME}:${VERSION}

echo "The 5 latest commits to your branch:"
git log ${cur_branch} --format=format:'%h - (%ai) %s — %an %d' --abbrev-commit --date=relative -5
