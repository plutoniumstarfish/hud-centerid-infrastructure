run "bucket_name_check" {
    variables {

    }
    command = plan

    assert {
        condition var.var_BUCKET_NAME == var.s3.deployment_bucket
        error_message = "Incorrect values"
    }
}