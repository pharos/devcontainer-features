#!/usr/bin/env bash

set -e

AWS_IAM_AUTHENTICATOR_VERSION="${VERSION:-"latest"}"

 if [ "$(id -u)" -ne 0 ]; then
 	echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
 	exit 1
 fi

ARCH="$(uname -m)"
if [ "${ARCH}" == "x86_64" ] ; then
		ARCH="amd64"
elif [ "${ARCH}" == "aarch64" ] || [ "${ARCH}" == "arm64" ] ; then
		ARCH="arm64"
else
	echo -e "unsupported arch: ${ARCH}"
	exit 1
fi

echo "downloading aws-iam-authenticator for arch '$ARCH'"

if [ "${AWS_IAM_AUTHENTICATOR_VERSION}" == "latest" ]; then
	DOWNLOAD_URL=$(curl -sL https://api.github.com/repos/kubernetes-sigs/aws-iam-authenticator/releases/latest | grep "browser_download_url.*linux_$ARCH" | cut -d : -f 2,3 | tr -d \" | xargs echo -n)
else
    DOWNLOAD_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_$ARCH"
fi

mkdir -p kubernetes-sigs
cd kubernetes-sigs

echo "downloading aws-iam-authenticator from '$DOWNLOAD_URL'"
curl -sL "$DOWNLOAD_URL" -o aws-iam-authenticator
chmod +x aws-iam-authenticator
./aws-iam-authenticator version
mv aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

cd -
rm -rf kubernetes-sigs
