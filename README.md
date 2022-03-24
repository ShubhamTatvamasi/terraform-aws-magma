# terraform-aws-magma

Use Terraform v1.0.11

Generate secrets:
```bash
mkdir -p certs && cd certs
../01-generate-secrets.sh orc8r.magmacore.link
cd ..
```

Initialize terraform:
```bash
terraform init
```

Setup orc8r infra:
```bash
terraform apply -target=module.orc8r
```

Setup secrets:
```bash
terraform apply -target=module.orc8r-app.null_resource.orc8r_seed_secrets

# For updating secrets taint it first:
terraform taint module.orc8r-app.null_resource.orc8r_seed_secrets
```

Delete secret if already exists:
```bash
aws secretsmanager delete-secret \
  --secret-id orc8r-secrets \
  --force-delete-without-recovery \
  --region us-east-2
```

Apply Everything:
```bash
terraform apply
```

Uninstall:
```bash
terraform destroy -target=module.orc8r-app
terraform destroy
```
