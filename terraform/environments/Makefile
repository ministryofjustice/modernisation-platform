BUCKET=modernisation-platform-terraform-state
KEY=providers-generated.tf

download_required_files:
	aws s3 cp s3://${BUCKET}/${KEY} ./${KEY}.tf
