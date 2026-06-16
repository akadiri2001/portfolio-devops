
terraform {

  backend "s3" {

    bucket       = "portfolio-tfstate-680692180764"

    key          = "portfolio/terraform.tfstate"

    region       = "eu-west-3"

    use_lockfile = true

    encrypt      = true

  }

}

