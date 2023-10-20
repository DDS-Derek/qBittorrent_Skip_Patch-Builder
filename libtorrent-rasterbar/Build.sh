#!/bin/bash

Green="\033[32m"
Red="\033[31m"
Yellow='\033[33m'
Font="\033[0m"
INFO="[${Green}INFO${Font}]"
ERROR="[${Red}ERROR${Font}]"
WARN="[${Yellow}WARN${Font}]"
function INFO() {
echo -e "${INFO} ${1}"
}
function ERROR() {
echo -e "${ERROR} ${1}"
}
function WARN() {
echo -e "${WARN} ${1}"
}


function get_info(){
WORKDIR=$(pwd)
INFO "WorkDir=${WORKDIR}"

CONFIG_FILE_DIR=/etc/DDSRem/config.json

Github_Token=$(jq -r '.Github_Token' ${CONFIG_FILE_DIR})
Dockerhub_Username=$(jq -r '.Dockerhub_Username' ${CONFIG_FILE_DIR})
Dockerhub_Password=$(jq -r '.Dockerhub_Password' ${CONFIG_FILE_DIR})
DockerHub_Repo_Name=$(jq -r '.DockerHub_Repo_Name' Build.json)
Github_Repo=$(jq -r '.Github_Repo' Build.json)
Branches=$(jq -r '.Branches' Build.json)
Version=$(eval echo $(jq -r '.Version' Build.json))
Dockerfile_Name=$(jq -r '.Dockerfile_Name' Build.json)
ARCH=$(jq -r '.ARCH' Build.json)
ARG=$(eval echo $(jq -r '.ARG' Build.json))
TAG=$(eval echo $(jq -r '.TAG' Build.json))
DockerHub_Repo="${Dockerhub_Username}/${DockerHub_Repo_Name}"
GITHUB_API=$(curl -H "Authorization: token ${Github_Token}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${Github_Repo})
image_created=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
image_description=$(echo ${GITHUB_API} | jq -r ".description")
image_licenses=$(echo ${GITHUB_API} | jq -r ".license.name")
image_revision=$(curl -H "Authorization: token ${Github_Token}" -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/${Github_Repo}/commits/${Branches} | jq -r ".sha")
image_source=$(echo ${GITHUB_API} | jq -r ".html_url")
image_title=$(echo ${GITHUB_API} | jq -r ".name")
image_url=$(echo ${GITHUB_API} | jq -r ".html_url")
image_version=${Version}

INFO "org.opencontainers.image.created=${image_created}"
INFO "org.opencontainers.image.description=${image_description}"
INFO "org.opencontainers.image.licenses=${image_licenses}"
INFO "org.opencontainers.image.revision=${image_revision}"
INFO "org.opencontainers.image.source=${image_source}"
INFO "org.opencontainers.image.title=${image_title}"
INFO "org.opencontainers.image.url=${image_url}"
INFO "org.opencontainers.image.version=${image_version}"
INFO "DockerHub_Repo_Name=${DockerHub_Repo_Name}"
INFO "DockerHub_Repo=${DockerHub_Repo}"
INFO "Github_Repo=${Github_Repo}"
INFO "Branches=${Branches}"
INFO "Version=${Version}"
INFO "Dockerfile_Name=${Dockerfile_Name}"
INFO "ARCH=${ARCH}"
INFO "ARG=${ARG}"
INFO "TAG=${TAG}"
}

function prepare_build() {
docker run -d \
    --name=builder_ddsrem \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v ${WORKDIR}:/build \
    --workdir /build \
    dockerhub.ddsrem.in:998/catthehacker/ubuntu@sha256:5c5b25525142c44ed8903e13ebcb4f9950a492402bb33d4ba493ca51c1f27dde tail -f /dev/null
docker exec -it builder_ddsrem uname -a
docker exec -it builder_ddsrem docker pull tonistiigi/binfmt
docker exec -it builder_ddsrem docker run --privileged --rm tonistiigi/binfmt --install all
docker exec -it builder_ddsrem docker buildx create --name builder --use 2>/dev/null || docker buildx use builder
docker exec -it builder_ddsrem docker buildx inspect --bootstrap
docker exec -it builder_ddsrem docker login --password ${Dockerhub_Password} --username ${Dockerhub_Username}
}

function clear_build() {
docker exec -it builder_ddsrem docker logout
docker exec -it builder_ddsrem docker buildx rm builder
docker stop builder_ddsrem
docker rm builder_ddsrem
docker image rm moby/buildkit:buildx-stable-1
}

function build_image() {
docker exec -it builder_ddsrem \
    docker buildx build \
    ${ARG} \
    --file ${Dockerfile_Name} \
    --label "org.opencontainers.image.created=${image_created}" \
    --label "org.opencontainers.image.description=${image_description}" \
    --label "org.opencontainers.image.licenses=${image_licenses}" \
    --label "org.opencontainers.image.revision=${image_revision}" \
    --label "org.opencontainers.image.source=${image_source}" \
    --label "org.opencontainers.image.title=${image_title}" \
    --label "org.opencontainers.image.url=${image_url}" \
    --label "org.opencontainers.image.version=${image_version}" \
    --platform ${ARCH} \
    ${TAG} \
    --push \
    .
}

get_info

prepare_build

build_image

clear_build