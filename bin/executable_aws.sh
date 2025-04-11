default_region="eu-west-1"

describe_image(){
	image_id=$1
	region=${2:-$default_region}

	aws ec2 describe-images --image-ids $image_id --region $region
}
table_of_amis(){
	owner_id=$1
	region=${2:-"eu-west-1"}
	name_search=${3:-"*"}

	aws ec2 describe-images \
		--owners $owner_id --query "sort_by(Images, &Name)[*].[CreationDate,Name,ImageId]" \
		--filters Name=name,Values="*${name_search}*" --region $region --output table
}
help(){
	cat <<EOF

aws.sh image|table ARGS

image: Get all attributes for a specific image (Use this to find f.ex. owner-id) 
  
	aws.sh image IMAGE_ID [REGION]

		ex. IMAGE_ID = ami-02fd62706c23e828f
		REGION (defaults to eu-west-1)

owner:

	aws.sh owner IMAGE_ID [REGION]

		ex. IMAGE_ID = ami-02fd62706c23e828f
		REGION (defaults to eu-west-1)

search: Look for images owned by a specific owner-id

	aws.sh search OWNER_ID [REGION [SEARCH_STRING]]

	ex.: search 979382823631 eu-west-1 "cassandra"


EOF
}


if [ $# -eq 0 ]; then
	action=help
else
	action=$1; shift
fi

case $action in 
	image)
		describe_image "$@"
		;;
	owner)
		describe_image "$@" | jq '.Images[].OwnerId'
		;; 
	search)
		table_of_amis "$@"
		;;
	help)
		help
		;;
esac
