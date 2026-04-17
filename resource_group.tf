module "resource_group" {
  source = "git::ssh://git@github.com/soribs/terraform-azure-child-of-projectA.git?ref=v1.0.0"

  resource_group_name = var.resource_group_name
  project_name        = var.project_name
}