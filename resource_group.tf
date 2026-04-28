module "resource_group" {
  source = "git::https://github.com/soribs/terraform-azure-child-of-projectA.git?ref=v1.0.1"

  resource_group_name = var.resource_group_name
  project_name        = var.project_name
}