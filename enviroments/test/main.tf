module "backend" {
  source = "../../modules/backend_s3"
}

module "organizations_scp" {
  source = "../../modules/organizations_scp"
}

# module "ec2-cw" {
#   source = "../../modules/ec2-cw"
# }

# module "cw_agent" {
#   source = "../../modules/cw-agent"
# }

# module "cloudTrail-lamnda-notification" {
#   source = "../../modules/cloudTrail-lamnda-notification"
# }
