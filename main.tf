################################################################################
# Copyright 2020 The Magma Authors.

# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree.

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################

module "orc8r" {
  source  = "ShubhamTatvamasi/orc8r/aws"
  version = "0.1.1"

  region = "us-east-2"

  # If you performing a fresh Orc8r install, choose a recent Postgres version
  # orc8r_db_engine_version     = "12.6"
  orc8r_db_password = "mypassword" # must be at least 8 characters

  setup_cert_manager = false

  secretsmanager_orc8r_secret = "orc8r-secrets"
  orc8r_domain_name           = "orc8r.magmacore.link"

  orc8r_sns_email             = "admin@magmacore.link"
  enable_aws_db_notifications = true

  vpc_name = "orc8r"

  deploy_elasticsearch          = true
  elasticsearch_domain_name     = "orc8r-es"
  elasticsearch_version         = "7.10"
  elasticsearch_instance_type   = "t2.medium.elasticsearch"
  elasticsearch_instance_count  = 2
  elasticsearch_az_count        = 2
  elasticsearch_ebs_enabled     = true
  elasticsearch_ebs_volume_size = 32
  elasticsearch_ebs_volume_type = "gp2"

  deploy_elasticsearch_service_linked_role = false
}

module "orc8r-app" {
  source  = "ShubhamTatvamasi/orc8r-helm/aws"
  version = "0.1.1"

  region = "us-east-2"

  orc8r_domain_name     = module.orc8r.orc8r_domain_name
  orc8r_route53_zone_id = module.orc8r.route53_zone_id
  external_dns_role_arn = module.orc8r.external_dns_role_arn

  secretsmanager_orc8r_name = module.orc8r.secretsmanager_secret_name
  seed_certs_dir            = "certs"

  deploy_cert_manager_helm_chart    = module.orc8r.setup_cert_manager
  managed_certs_create              = module.orc8r.setup_cert_manager
  managed_certs_enabled             = module.orc8r.setup_cert_manager
  nms_managed_certs_enabled         = module.orc8r.setup_cert_manager
  cert_manager_route53_iam_role_arn = module.orc8r.cert_manager_route53_iam_role_arn

  orc8r_db_host    = module.orc8r.orc8r_db_host
  orc8r_db_port    = module.orc8r.orc8r_db_port
  orc8r_db_dialect = module.orc8r.orc8r_db_dialect
  orc8r_db_name    = module.orc8r.orc8r_db_name
  orc8r_db_user    = module.orc8r.orc8r_db_user
  orc8r_db_pass    = module.orc8r.orc8r_db_pass

  # Note that this can be any container registry provider
  docker_registry = "shubhamtatvamasi"
  docker_user     = ""
  docker_pass     = ""

  # Note that this can be any Helm chart repo provider
  helm_repo      = "https://shubhamtatvamasi.github.io/magma-charts-3-17-2022"
  helm_user      = ""
  helm_pass      = ""
  eks_cluster_id = module.orc8r.eks_cluster_id

  efs_file_system_id       = module.orc8r.efs_file_system_id
  efs_provisioner_role_arn = module.orc8r.efs_provisioner_role_arn

  elasticsearch_endpoint       = module.orc8r.es_endpoint
  elasticsearch_disk_threshold = tonumber(module.orc8r.es_volume_size * 75 / 100)

  orc8r_deployment_type = "fwa"
  orc8r_tag             = "b1ade1f"
}

output "nameservers" {
  value = module.orc8r.route53_nameservers
}
