locals {
  resource_name_prefix = "${var.location_code}-${var.environment}"

  split_resource_name_prefix             = split("-", local.resource_name_prefix)
  resource_name_prefix_capitalized_parts = [for part in local.split_resource_name_prefix : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_resource_name_prefix       = join("", local.resource_name_prefix_capitalized_parts)
}

#여기까지는 just au-stg -> au, stg -> AuStg 그냥 string formatting 가지고 노는거임. Nothing technical.