
data "vault_generic_secret" "aws-creds" {
  path = "secret/home/gowrishankar/Downloads"

}

provider "aws" {
  region     = data.vault_generic_secret.aws-creds.data["region"]
  access_key = data.vault_generic_secret.aws-creds.data["aws_access_key"]
  secret_key = data.vault_generic_secret.aws-creds.data["aws_secret_access_key"]
}
