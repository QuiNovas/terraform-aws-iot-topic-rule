locals{
	s3_bucket_arns = formatlist("arn:aws:s3:::%s/*", var.s3.*.bucket_name)
}