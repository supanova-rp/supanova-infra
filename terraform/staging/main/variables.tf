variable "staging_env_file" {
  description = "Path to the local .env.staging file"
  type        = string
  default     = "../../../.env.staging"
}

variable "firebase_config_file" {
  description = "Path to the local firebase config file"
  type        = string
  default     = "../../../firebase/supanova-firebase-config.json"
}

variable "users_sql_file" {
  description = "Path to the local users.sql file"
  type        = string
  default     = "../../../database/sql/users.sql"
}

variable "nginx_conf_file" {
  description = "Path to the local nginx config file"
  type        = string
  default     = "../../nginx.conf"
}
