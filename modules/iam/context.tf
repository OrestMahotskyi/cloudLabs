# Цей файл є стандартним для використання модуля terraform-null-label.
# Він дозволяє передавати налаштування іменування між модулями.

variable "context" {
  type = any
  default = {
    enabled             = true
    namespace           = null
    tenant              = null
    environment         = null
    stage               = null
    name                = null
    delimiter           = null
    attributes          = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = null
    label_order         = []
    id_length_limit     = null
    label_key_case      = null
    label_value_case    = null
    descriptor_formats  = {}
    labels_as_tags      = ["unset"]
  }
  description = "Default context to use for passing state between modules"
}

variable "enabled" {
  type        = bool
  default     = null
  description = "Set to false to prevent the module from creating any resources"
}

variable "namespace" {
  type        = string
  default     = null
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
}

variable "tenant" {
  type        = string
  default     = null
  description = "ID element _(allurs)_"
}

variable "environment" {
  type        = string
  default     = null
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "stage" {
  type        = string
  default     = null
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
}

variable "name" {
  type        = string
  default     = null
  description = "ID element. Usually the component name"
}

variable "delimiter" {
  type        = string
  default     = null
  description = "Delimiter to be used between ID elements"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "ID element. Additional attributes (e.g. `worker`, `pool` etc.)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`)"
}

variable "additional_tag_map" {
  type        = map(string)
  default     = {}
  description = "Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`."
}

variable "label_order" {
  type        = list(string)
  default     = null
  description = "The order in which the labels (ID elements) appear in the `id`."
}

variable "regex_replace_chars" {
  type        = string
  default     = null
  description = "Terraform regular expression (regex) string"
}

variable "id_length_limit" {
  type        = number
  default     = null
  description = "Limit `id` to this many characters"
}

variable "label_key_case" {
  type        = string
  default     = null
  description = "The case for the keys in `tags`. Valid values: `lower`, `upper`, `title`, `none`"
}

variable "label_value_case" {
  type        = string
  default     = null
  description = "The case for the values in `tags`. Valid values: `lower`, `upper`, `title`, `none`"
}

variable "descriptor_formats" {
  type        = any
  default     = {}
  description = "Describe additional descriptors to be output in the `descriptors` output map"
}

variable "labels_as_tags" {
  type        = list(string)
  default     = ["unset"]
  description = "The set of labels (ID elements) to include as tags in the `tags` output"
}