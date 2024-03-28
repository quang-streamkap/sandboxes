variable "nuon_id" {
  type        = string
  description = "The nuon id for this install. Used for naming purposes."
}

variable "tags" {
  type        = map(string)
  description = "List of custom tags to add to the install resources. Used for taxonomic purposes."
}

variable "location" {
  type        = string
  description = "The location to launch the cluster in"
}
