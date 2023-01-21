terraform {
  backend "s3" {
    #bucket = "terraformstatecdg"
    #key    = "cdg/terraform.tfstate"
    region = "us-east-1"



    # For State Locking
    #dynamodb_table = "CdgTfStateTable"

    bucket = "clouddevopsbabies-tf-state"
    key    = "newversion/terraform.tfstate"



    # For State Locking
    dynamodb_table = "poc-clouddevopsbabies-tf-state"
  }

}