# terraform-handson

Terraform GCP Hands-on (Task 1) – MIG with LB, Storage & Secrets
Executive Summary
This project uses Terraform to build a Google Cloud environment with a Managed Instance Group (MIG), an external HTTP(S) Load Balancer, a Cloud Storage bucket, and a Secret Manager secret. We follow best practices by using modular Terraform code, remote state (optional), and principle-of-least-privilege (PoLP) identity setup. A dedicated Service Account is created for the VMs to securely fetch secrets at startup. Sensitive values (e.g. database passwords) are kept in Secret Manager rather than in code. This README explains the purpose, architecture, structure, setup steps, security considerations, and common troubleshooting for this Terraform project.

Purpose and Architecture
We aim to deploy a simple, scalable web tier on GCP:

A Managed Instance Group (MIG) of Compute Engine VMs running a startup script.
A Global External HTTP Load Balancer routing traffic to the MIG.
A Cloud Storage bucket (e.g. for serving static assets or backups).
A Secret (app-password) stored in Secret Manager, accessed by VMs via a service account.
Key principles:

Least Privilege IAM – VMs use a dedicated service account with only the Secret Manager Accessor role on the specific secret.
No hard-coded secrets – Secret values live only in Secret Manager; Terraform code never contains plaintext secrets.
Reproducible infrastructure – All resources are defined in Terraform modules for modularity and reuse.
Below is a simplified architecture flow:

mermaid
Copy
graph LR
  A[Clients] -- HTTP/HTTPS --> B[Global HTTP Load Balancer]
  B --> C[MIG (instance group)]
  C --> D[Compute Instance]
  D -- Startup Script --> E[gcloud SDK]
  E --> F[Secret Manager API] 
  F --> G[Secret: app-password]

  subgraph Identity
    H[Service Account: mig-vm-sa]
    H -- has roles/secretmanager.secretAccessor --> F
    D --> H  &nbsp;&nbsp;&nbsp;(**Attached to each VM**)
  end

  subgraph Storage
    I[Cloud Storage Bucket]
  end
  B -- Backend Buckets or Backends --> I
Each VM in the MIG runs a startup script that invokes the Google Cloud SDK to retrieve app-password from Secret Manager (via gcloud secrets versions access ...). Secret Manager checks the VM’s service account (attached via the instance template) and allows access because we granted it the roles/secretmanager.secretAccessor role. The load balancer front-ends the VM group, and a storage bucket is available for other uses (e.g. logs or static files).

Repository Structure
The repository terraform-handson (Task 1) is organized as follows:

File/Dir	Description
task1/main.tf	Root configuration invoking modules and defining variables.
task1/provider.tf	Provider setup (GCP project, region).
task1/backend.tf	Terraform backend configuration (local by default).
task1/variables.tf	Input variables (project_id, region, etc.).
task1/outputs.tf	Outputs (e.g. load balancer IP, bucket name).
task1/terraform.tfvars	Values for variables (project_id, region, etc.).
task1/.gitignore	Git ignore rules (state files, .terraform/, etc.).
task1/modules/	Directory for reusable modules:
├── network/	(Optional) VPC/network setup (if used).
├── compute/	Instance template & MIG.
├── autoscaler/	Autoscaler for MIG.
├── loadbalancer/	HTTP(S) load balancer (frontend, forwarding rule, backends).
├── cloudstorage/	Cloud Storage bucket resource.
├── secretmanager/	Secret Manager secret (and version) configuration.
└── iam/	IAM resources (service account, role binding).

Each module has its own main.tf, variables.tf, and outputs.tf. The iam module creates mig-vm-sa and binds it to roles/secretmanager.secretAccessor for the project. The compute module uses mig-vm-sa (provided from the iam outputs) in the instance template. The secretmanager module can create the secret (or it may already be created via gcloud secrets create).

Note: The .terraform.lock.hcl (provider lock file) is not in .gitignore. Per Terraform guidance, you should commit this lock file so that provider versions are fixed and reproducible. This avoids unintended upgrades of provider plugins.

Prerequisites
Before running this project:

OS: Linux, macOS, or WSL2 on Windows. (For Windows, using WSL2 with Git is recommended to avoid path/credential issues).
Terraform: Install Terraform (v1.x). We recommend at least v1.5 or later for stability. Install from terraform.io.
gcloud CLI: Install the Google Cloud SDK (gcloud). Authenticate with gcloud auth login and set the project (gcloud config set project YOUR_PROJECT_ID).
Git: Installed and configured with your GitHub account.
(Optional) GitHub CLI: Installing gh can simplify authentication (gh auth login) and repository management.
Google Provider: The Terraform Google provider is used. No hard constraint, but ensure your required_providers block includes a recent hashicorp/google version compatible with your Terraform (secret manager support is available in stable provider versions). See Terraform Google provider docs.
Environment setup typically includes:

bash
Copy
gcloud init
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
The last command sets up [Application Default Credentials] on your local machine for Terraform to use the Google provider without explicit credentials (preferred over service account JSON files).

Setup & Deployment
Below are the exact steps to prepare the repository and deploy the infrastructure:

1. Clone the Repository
bash
Copy
git clone https://github.com/prithvi-A24/terraform-handson.git
cd terraform-handson
Or, using SSH (after adding your SSH key to GitHub):

bash
Copy
git clone git@github.com:prithvi-A24/terraform-handson.git
cd terraform-handson
If using HTTPS, do not enter your GitHub password when prompted. GitHub requires a Personal Access Token (PAT) or an SSH key for authentication. Generate a PAT with the repo scope from GitHub Settings → Developer Settings (or use a fine-grained token with repo access). Use it as the “password” when prompted. Alternatively, set up SSH once (generate ssh-keygen -t ed25519) and use the SSH clone URL to avoid password prompts.

2. Project Structure
Create the task1 directory (if not already present) and copy the Terraform code into it:

bash
Copy
mkdir task1
cp -r path/to/terraform-mig-demo/* task1/
Ensure your .gitignore is in task1/ with entries like:

gitignore
Copy
# Terraform
.terraform/
*.tfstate
*.tfstate.*
crash.log

# Variables containing secrets
*.tfvars
*.tfvars.json

# Editor files
.vscode/
.idea/
We do not ignore .terraform.lock.hcl because it should be committed. This ensures consistent provider versions for all users.

3. Review Configuration
backend.tf: Configures the Terraform backend. By default it may be local, but consider using a remote backend (see State Migration below).
provider.tf: Contains the google provider and project/region variables.
variables.tf / terraform.tfvars: Define project_id, region, zone, machine_type, etc. Populate terraform.tfvars with your project and region (no sensitive data).
modules/: Review each module’s variables. For example, the compute module may take service_account_email to attach to the instance template.
iam module: Check service_account.mig_vm and project_iam_member settings (assigns roles/secretmanager.secretAccessor).
4. Initialize Terraform
bash
Copy
cd task1
terraform init
This installs providers and initializes the (default local) backend.
If prompted about migrating state (e.g. after configuring a new backend), you may need to run with -migrate-state (see State Migration section).
Outputs: After a successful terraform init, you should see messages about installed providers (e.g. Google provider, random provider, etc.).

5. Plan and Apply
bash
Copy
terraform plan -out=plan.out
terraform apply plan.out
Review the plan to ensure resources (MIG, LB, bucket, etc.) are as expected.
Approve apply. Terraform will create the resources in order (IAM service account, storage bucket, instance template/MIG, load balancer, etc.).
After apply, Terraform outputs may include values like the load balancer IP and bucket name. Save these if needed.

6. Testing the Deployment
Compute Instances: Check the MIG status:
bash
Copy
gcloud compute instance-groups managed list
gcloud compute instance-groups managed describe <group-name> --region <region>
VM Health: Ensure VMs booted and ran the startup script. You can check serial port output or the metadata server logs:
bash
Copy
gcloud compute instances get-serial-port-output <instance-name> --zone <zone>
Load Balancer: Test the public IP or domain. For example:
bash
Copy
LB_IP=$(terraform output -raw load_balancer_ip)
curl http://$LB_IP
You should see a response served by the MIG’s instances.
Secret Access: Verify the secret is fetched. The startup script might write the secret to a file or log. Confirm via VM logs or SSH into a VM and check the application’s configuration (which should contain the app-password value). You can also manually test Secret Manager access:
bash
Copy
gcloud secrets versions access latest --secret="app-password"
The output should be the secret value (e.g. MySuperSecretPassword123). This proves the mig-vm-sa has roles/secretmanager.secretAccessor access.
Storage Bucket: Verify the bucket exists:
bash
Copy
gcloud storage ls gs://<bucket-name>
Secrets Management
This project stores sensitive data in Google Secret Manager. The password (app-password) is never written in Terraform code or Git. Instead:

Creating the Secret: The secret resource may be created by Terraform (in modules/secretmanager). If it’s manual, you can use:
bash
Copy
echo -n "MySuperSecretPassword123" | gcloud secrets create app-password --data-file=- --replication-policy="automatic"
Service Account: We created a service account mig-vm-sa in the iam module. The terraform google_project_iam_member grants it roles/secretmanager.secretAccessor on the project. This is least-privilege: it can only read secrets, not modify them. As Secret Manager docs note, grant only the minimum role needed (Secret Accessor for reading).
Accessing the Secret: In the instance template (in the compute module), we attach the service account:
hcl
Copy
service_account {
  email  = var.service_account_email  # mig-vm-sa email from IAM module output
  scopes = ["cloud-platform"]
}
Each VM on startup runs a script like:
bash
Copy
SECRET=$(gcloud secrets versions access latest --secret="app-password")
# use $SECRET in app configuration...
This flow is: VM (via metadata identity) → Secret Manager → returns the secret value if IAM allows. The pod/client libraries use Google’s ADC (Application Default Credentials) or metadata, which is secure.
Avoiding Leaks: We do not pass secrets via environment variables or files in source code, as recommended by Google’s security guidelines. Instead, the startup script fetches the secret at runtime, minimizing exposure. The retrieved secret ends up in the VM’s memory or disk at startup (ephemeral) and in Terraform’s state if we ever data-source it (be cautious – see [Seth Vargo’s warning][16]). By using a remote backend and secure IAM, we mitigate state-file risk.
Rotation: As a best practice, secrets should be rotated periodically. For example, use gcloud secrets versions add with a new value and update the VMs or reload config to use the new version. Secret Manager supports automated rotation (with Cloud Scheduler or Cloud Functions) – plan to rotate production secrets every so often to limit exposure.
CI/CD and Git Workflow
For collaboration and continuous deployment, adopt a Git workflow:

Branching: Use feature branches (e.g. feature/mig-setup) and open Pull Requests (PRs) before merging to main.
Code Review: Peer review Terraform changes via PR. This catches errors and sensitive leaks.
Actions or CI: Configure GitHub Actions (or another CI) to terraform fmt -check, terraform validate, and optionally terraform plan on PRs. For example, HashiCorp provides [GitHub Actions for Terraform][32], though self-hosted runners can also run terraform plan. This ensures that invalid Terraform code or drift is caught before merging.
Protected Branches: Protect main branch (require PR reviews, passing checks). Only merge after reviews and approvals.
Deployment: After PR merge, manually (or automatically) terraform apply from main. For non-production, you might auto-apply on merge; for production, require manual approval.
Secrets in CI: Store any needed secrets (like GCP service account keys, PATs) in GitHub Secrets. Use least privileges (e.g. a short-lived service account with limited IAM for CI). Rotate those secrets periodically.
GitHub’s advice: “Automate Terraform with CI/CD” enforces best practices and collaboration. Use GitHub CLI (gh auth login) or SSH keys to avoid interactive auth in scripts.

Security Best Practices
This project follows several security guidelines:

Do NOT commit sensitive data: All secrets reside in Secret Manager, not in Terraform or Git. Terraform state is ignored (*.tfstate in .gitignore).
State file protection: The Terraform state may contain non-secret metadata. If local, ensure terraform.tfstate and backups are in .gitignore. For multi-user work, use a remote backend like a GCS bucket with tight IAM (read/write only to admins). See State Migration below.
.gitignore rules: We ignore .terraform/ (provider plugins), *.tfstate, *.tfvars (since tfvars could contain secrets). Do not ignore .terraform.lock.hcl – commit it!.
Lock File: Committing .terraform.lock.hcl freezes provider versions. Terraform docs say you should commit the lock file so that “you can discuss potential changes to your external dependencies via code review”. This prevents unintended upgrades of providers. Follow the practice of other ecosystems (like package-lock.json in npm).
Least Privilege: The VM’s service account has only roles/secretmanager.secretAccessor for the project or ideally just the one secret. It cannot delete or manage secrets. We did not use editor or owner. Secret Manager docs emphasize granting only needed permissions.
Rotate secrets: Plan for periodic rotation of the secret (Secret Manager supports scheduled rotation with Cloud Scheduler). Rotation limits risk if a secret is compromised.
PAT vs SSH: For GitHub, prefer SSH keys or a fine-grained PAT. Classic PAT (with broad repo scope) is less secure than SSH or a fine-grained token (tied to this repo). GitHub recommends fine-grained tokens or SSH for long-term security.
Zero trust environment: Credentials are provided via ADC / metadata (no key files stored on disk). On local dev, use gcloud auth application-default login, and in CI use Workload Identity or service-account keys with minimal scopes.
