module "backend" {
  source = "../../modules/backend_s3"
}

module "organizations_scp" {
  source = "../../modules/organizations_scp"
}
