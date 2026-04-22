eval $(crc oc-env)

if [ -z $1 ]; then
	USER=developer
else
	USER=$1
fi
oc login -u $USER https://api.crc.testing:6443

source <(oc completion bash)
