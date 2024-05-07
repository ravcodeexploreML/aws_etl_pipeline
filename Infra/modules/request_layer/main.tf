# create zip file from requirements.txt. Triggers only when the file is updated
# first method 
resource "null_resource" "lambda_layer" {
  triggers = {
    requirements = filesha1(var.requirements_path)
  }
  # the command to install python and dependencies to the machine and zips
  provisioner "local-exec" {
    command = <<EOT
      set -e
      rm -rf python
      mkdir python
      python3 -m venv venv_layer
      . venv_layer/bin/activate 
      pip3 install -r ${var.requirements_path}
      cp -r venv_layer/lib python
      zip -r ${var.layer_zip_path} python/
      rm -rf venv_layer
      rm -rf python
    EOT
  }
}

resource "aws_s3_bucket" "lambda_layer_bucket" {
  bucket = var.lambda_layer_bucket_name
}

resource "aws_s3_object" "lambda_layer_zip" {
    bucket   = aws_s3_bucket.lambda_layer_bucket.id
    key      =  "${var.lambda_layer}/${var.layer_name}/${var.layer_zip_path}"
    source     = var.layer_zip_path
    depends_on = [null_resource.lambda_layer] # triggered only if the zip file is created
    #content_type = "application/x-directory"  
}




## second method
/*
data "archive_file" "layer" {
  type        = "zip"
  source_dir  = var.path_to_request_layer_source
  output_path = var.path_to_request_layer_artifact
}



resource "aws_lambda_layer_version" "requests_layer" {
  filename   = var.path_to_request_layer_filename
  layer_name = var.request_layer_name
  source_code_hash    = filebase64sha256(var.path_to_request_layer_filename)

  compatible_runtimes      = var.compatible_layer_runtimes
  compatible_architectures = var.compatible_architectures
}

*/