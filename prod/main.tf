terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.63.0"
    }
  }

  backend "s3" {
    bucket         = "sk-terraform-state-bucket"
    key            = "terraform-prod.tfstate"
    region         = ${{ secrets.SNOWFLAKE.REGION }}
    # Optional DynamoDB for state locking. See https://developer.hashicorp.com/terraform/language/settings/backends/s3 for details.
    # dynamodb_table = "terraform-state-lock-table"
    encrypt        = true
    role_arn       = "arn:aws:iam::<your-aws-account-no>:role/<terraform-s3-backend-access-role>"
  }
}

provider "snowflake" {
  username    = ${{ secrets.SNOWFLAKE.USERNAME }}
  account     = ${{ secrets.SNOWFLAKE.ACCOUNT }}
  role        = ${{ secrets.SNOWFLAKE.ROLE }}
  private_key = var.snowflake_private_key
}

module "snowflake_resources" {
  source              = "../modules/snowflake_resources"
  time_travel_in_days = 30
  database            = var.database
  env_name            = var.env_name
}