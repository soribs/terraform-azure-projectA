module "resource_group" {
  source = "git::ssh://git@github.com/soribs/terraform-azure-child-of-projectA.git?ref=v1.0.1"

<<<<<<< HEAD
  resource_group_name = var.resource_group_name
  project_name        = var.project_name
=======
  tags = local.common_tags
>>>>>>> 6f056d73d98810ad6938c3120a0dd91a558f66b7
}