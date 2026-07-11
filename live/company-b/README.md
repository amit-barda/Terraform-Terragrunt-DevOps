# company-b (placeholder)

This company is intentionally left as a **structure-only placeholder** to
demonstrate that the repository scales to multiple companies without any
changes to the root `terragrunt.hcl` or to `modules/`.

Each environment already has its own `account.hcl` / `env.hcl` / `region.hcl`
pointing at a distinct placeholder AWS account. To bring company-b to life:

1. Replace the placeholder `account_id` values in `staging/account.hcl` and
   `production/account.hcl` with real AWS account IDs.
2. Create component directories the same way as `company-a/production`, e.g.
   `staging/networking/terragrunt.hcl`, `staging/ecs-cluster/terragrunt.hcl`, etc.,
   each pointing at the shared modules under `modules/`.
3. Run `terragrunt run-all plan` from within `live/company-b/<environment>`.

No module code needs to change - the same `modules/networking`,
`modules/ecs-cluster`, `modules/ecs-service`, and `modules/alb` are reused.
