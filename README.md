# Terraform Fundamentals — Assignment

This repository records my practice with Terraform and AWS EC2. The examples progress from creating a single resource, to changing and destroying it, to using variables, outputs, and remote state in Amazon S3.

## What I Learned

| Tutorial | Topic | My Takeaway |
|---|---|---|
| 03 | Build infrastructure | `terraform init` installs the AWS provider, `plan` previews changes, and `apply` creates the infrastructure declared in code. |
| 04 | Change infrastructure | Terraform compares configuration with state and proposes only the required change. The plan must be reviewed before applying it. |
| 05 | Destroy infrastructure | `terraform destroy` removes resources tracked by the current state. It is important for avoiding unexpected AWS charges during practice. |
| 06 | Input variables | Variables keep configuration reusable. `variables.tf`, defaults, and `terraform.tfvars` allow values such as the region, AMI, instance type, and name to be changed without editing the resource block. |
| 07 | Outputs | Output blocks expose resource attributes such as an instance ID, public IP, and ARN after apply. |
| 08 | Remote state with S3 | An S3 backend stores Terraform state remotely. Versioning protects state history, and `use_lockfile = true` enables native S3 state locking in modern Terraform. |

## Repository Structure

```text
03-build-infrastructure/       Create an EC2 instance
04-change-infrastructure/      Change the declared infrastructure
05-destroy-infrastructure/     Practice destroying an EC2 instance
06-input-variables/            Use variables for reusable configuration
07-outputs/                    Print selected resource attributes
08-remote-state-s3/
  bootstrap/                   Create the S3 state bucket using local state
  main.tf                      Use the S3 backend for the application state
screenshots/                   Screenshots referenced throughout this README
README.md
```

Each numbered folder is an independent Terraform root module with its own state. A command run in one folder does not use outputs or state from another folder.

## Prerequisites

- Terraform installed and available as `terraform` in the terminal
- An AWS account and credentials configured for the AWS CLI/provider
- Permission to create and delete EC2 and S3 resources in `ap-south-1`
- An AMI that exists in `ap-south-1`; AMI IDs are region-specific

Check the installation and AWS identity before applying:

```bash
terraform version
aws sts get-caller-identity
```

## Installation Steps

### 1. Install AWS CLI

**Windows**
1. Download the AWS CLI MSI installer: https://awscli.amazonaws.com/AWSCLIV2.msi
2. Run the installer and follow the prompts.
3. Verify installation:
   ```bash
   aws --version
   ```

**macOS**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
aws --version
```

**Linux**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
```

**Configure credentials**
```bash
aws configure
```
You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g. `ap-south-1`)
- Default output format (e.g. `json`)

Verify it's working:
```bash
aws sts get-caller-identity
```

### 2. Install Terraform

**Windows (Chocolatey)**
```bash
choco install terraform
```

**Windows (manual)**
1. Download the binary: https://developer.hashicorp.com/terraform/install
2. Unzip it and place `terraform.exe` in a folder.
3. Add that folder to your system `PATH` environment variable.

**macOS (Homebrew)**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

Verify installation:
```bash
terraform -version
```

### 3. Set Up VS Code

1. Install [VS Code](https://code.visualstudio.com/).
2. Install the **HashiCorp Terraform** extension:
   - Open VS Code → Extensions (`Ctrl+Shift+X`)
   - Search for `HashiCorp Terraform`
   - Click **Install**
   - This gives you syntax highlighting, autocomplete, formatting, and validation for `.tf` files.
3. (Optional) Install the **AWS Toolkit** extension for AWS resource browsing and credential management inside VS Code.
4. Enable format-on-save for Terraform files by adding this to your VS Code `settings.json`:
   ```json
   {
     "[terraform]": {
       "editor.formatOnSave": true
     }
   }
   ```

### 4. Quick Sanity Check

```bash
aws --version
terraform -version
aws sts get-caller-identity
```

If all three commands return output without errors, you're ready to run `terraform init`.

## Standard Workflow

Run these commands from the selected tutorial directory:

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Terraform asks for confirmation during `apply`. Enter `yes`, or use `terraform apply --auto-approve` for a non-interactive practice run. Inspect the result and clean up when finished:

```bash
terraform state list
terraform destroy
```

## Tutorial Commands

### 03: Build Infrastructure

```bash
cd 03-build-infrastructure
terraform init
terraform validate
terraform plan
terraform apply 
```

![Terraform apply](screenshots/03-terraform-apply.png)
![Terraform apply result on AWS](screenshots/03-terraform-apply-result-on-aws.png)

This creates an EC2 instance named `AppServerInstance` using an AMI and a `t2.micro` instance type.

```bash
cd ../05-destroy-infrastructure
terraform destroy
```

![Terraform destroy](screenshots/03-terraform-destroy.png)
![Terraform destroy result on AWS](screenshots/03-terraform-destroy-result-on-aws.png)

### 04: Change Infrastructure

```bash
cd 04-change-infrastructure
terraform init
terraform plan
terraform apply
```

![Terraform apply](screenshots/04-terraform-apply.png)
![Terraform apply result on AWS](screenshots/04-terraform-apply-result-on-aws.png)

The changed configuration demonstrates that Terraform can update existing infrastructure based on the difference between configuration and state.

```bash
cd ../05-destroy-updated-infrastructure
terraform destroy
```

![Terraform destroy](screenshots/04-terraform-destroy.png)
![Terraform destroy result on AWS](screenshots/04-terraform-destroy-result-on-aws.png)

The learning objective here is the destroy workflow — only resources managed by the current state are targeted.

### 06: Input Variables

```bash
cd 06-input-variables
terraform init
terraform validate
terraform plan
terraform apply
```

![Terraform apply](screenshots/06-terraform-apply.png)
![Terraform apply result on AWS](screenshots/06-terraform-apply-result-on-aws.png)

```bash
terraform state show aws_instance.app_server
terraform destroy
```

![Terraform destroy](screenshots/06-terraform-destroy.png)
![Terraform destroy result on AWS](screenshots/06-terraform-destroy-result-on-aws.png)

The default values are defined in `variables.tf`. To customize them, copy `terraform.tfvars.example` to `terraform.tfvars` and edit the values before running `plan` or `apply`:

```bash
cp terraform.tfvars.example terraform.tfvars
terraform plan
```

> Do not commit sensitive values in `terraform.tfvars`.

### 07: Outputs

```bash
cd 07-outputs
terraform init
terraform validate
terraform plan
terraform apply
```

![Terraform apply](screenshots/07-terraform-apply.png)
![Terraform apply result on AWS](screenshots/07-terraform-apply-result-on-aws.png)

```bash
terraform output
terraform output instance_id
terraform output -raw instance_public_ip
terraform destroy
```

![Terraform destroy](screenshots/07-terraform-destroy.png)
![Terraform destroy result on AWS](screenshots/07-terraform-destroy-on-aws.png)

The available outputs are:

- `instance_id` — the EC2 instance ID
- `instance_public_ip` — the assigned public IP address, when one is available
- `instance_arn` — the AWS ARN of the instance

Outputs are printed only when `apply` is run in this directory, because the output definitions and state belong to this directory.

### 08: Remote State with S3

The S3 bucket must be created before the main configuration can initialize its backend. The `bootstrap` directory intentionally uses local state so it can create the bucket needed by the remote backend.

1. Choose a globally unique bucket name. The current example uses `terraform-state-bucket-for-ubuntu-12345`.
2. Use the same bucket name in `bootstrap/main.tf` and `08-remote-state-s3/main.tf`.
3. Create the bucket:

   ```bash
   cd 08-remote-state-s3/bootstrap
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```

   ![Terraform apply for bucket](screenshots/08-terraform-apply-for-bucket.png)
   ![Terraform apply result for bucket on AWS](screenshots/08-terraform-apply-result-for-bucket-on-aws.png)

   ```bash
   terraform output bucket_name
   ```

4. Initialize the main configuration and migrate its local state to S3:

   ```bash
   cd ..
   terraform init
   ```

   When Terraform asks to migrate existing state, answer `yes`. Then apply the EC2 configuration:

   ```bash
   terraform validate
   terraform plan
   terraform apply
   ```

   ![Terraform apply for server creation](screenshots/08-terraform-apply-for-server-creation.png)
   ![Terraform apply result for server creation on AWS](screenshots/08-terraform-apply-result-for-server-creation-on-aws.png)

   ```bash
   terraform output instance_public_ip
   ```

5. Clean up in the correct order:

   ```bash
   terraform destroy
   ```

   ![Terraform destroy for server](screenshots/08-terraform-destroy-for-server.png)
   ![Terraform destroy result for server on AWS](screenshots/08-terraform-destroy-result-for-server-on-aws.png)

   ```bash
   cd bootstrap
   terraform destroy
   ```

   ![Terraform destroy for bucket](screenshots/08-terraform-destroy-for-bucket.png)
   ![Terraform destroy result for bucket on AWS](screenshots/08-terraform-destroy-result-for-bucket-on-aws.png)

> Destroy the application resources before destroying the bucket. In a real shared environment, do not delete a state bucket until all users and workspaces have been migrated elsewhere.

## Mistakes Resolved

### S3 backend initialization failed with `NoSuchBucket`

The main configuration was initialized before the backend bucket existed, or it still referenced the placeholder bucket name `my-terraform-state-bucket-CHANGE-ME-12345`.

**Resolution:** apply `08-remote-state-s3/bootstrap` first, use the same real bucket name in both Terraform files, and only then run `terraform init` in `08-remote-state-s3`.

### `terraform destroy` failed with `BucketNotEmpty`

The state bucket had versioning enabled, and it still contained the `terraform.tfstate` object (and its versions) written by the main configuration. S3 will not delete a bucket until every object and every version inside it is removed — even if the bucket looks empty in a normal listing.

**Resolution:** destroy the main configuration first so the state object is removed, or manually clear all object versions and delete markers from the bucket (via the AWS CLI or the console's "Show versions" view) before destroying the bootstrap bucket. For disposable practice buckets, `force_destroy = true` on the `aws_s3_bucket` resource avoids this entirely — but this should never be used on a real, shared state bucket.

### The bucket name was confusing

S3 bucket names are globally unique, not merely unique within my AWS account. A tutorial placeholder can therefore fail or point to a bucket that does not exist.

**Resolution:** replace the placeholder with a unique name and keep the bootstrap and backend names identical.

### The wrong directory was used

Terraform reads the `.tf` files and state associated with the current working directory. Running from the repository parent or another tutorial directory changes which configuration Terraform uses.

**Resolution:** confirm the path before every command:

```bash
pwd
```

## Important Terraform Concepts

- **Configuration** — the `.tf` files describing the desired infrastructure.
- **Provider** — translates Terraform resources into API calls (e.g. the AWS provider).
- **State** — Terraform's record of the resources it manages.
- **Plan** — a preview of changes before they happen.
- **Apply** — creates or updates resources to match configuration.
- **Output** — a named value exposed from state after apply.
- **Backend** — the location and method used to store state. The S3 backend stores it remotely and supports locking.
- **Bootstrap** — a separate first step used to create infrastructure required by the main configuration.

## Cost and Cleanup

EC2 instances and other AWS resources can incur charges. After practice, verify the resources are gone:

```bash
terraform state list
terraform destroy
```

For the remote-state exercise, confirm the application state has been destroyed before removing the bootstrap S3 bucket. In a production setup, protect the state bucket with stricter lifecycle and deletion policies than this assignment uses.