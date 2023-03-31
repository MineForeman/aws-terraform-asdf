# Configuration Guide for the Project

This guide provides instructions and examples for configuring the project, including how to set up environment variables, configure Terraform, Ansible, Packer settings, and customize components.

## Environment Variables

A few key environment variables are essential for the project components to function correctly. These may include AWS credentials, directory paths, or other custom settings.

For example, set your AWS credentials as environment variables:

```bash
export AWS_ACCESS_KEY_ID=your_access_key_id
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

**Note:** You can also configure these credentials in a configuration file (i.e., `~/.aws/credentials`) using a named profile.

### Custom Variables

Other environment variables may be required for specific components like Terraform, Ansible, or Packer. Ensure you set all required environment variables documented in the `README.md` or respective component files.

## Terraform Configuration

Terraform requires several `*.tf` files, specifying different resources to be provisioned or managed. This might include `.tfvars` files, which contain default values for your input variables. Update these as needed for your specific project and environment.

### Variable Declarations

Edit the existing `variables.tf` file, or create a custom one, to declare input variables and their types:

```hcl
variable "vpc_name" {
    type = string
}
```

### Variable Assignments

Create or modify `terraform.tfvars` file to assign values to input variables:

```hcl
vpc_name = "my-custom-vpc"
```

## Ansible Playbooks Configuration

Ansible playbooks located in the `ansible/` directory are used for automating server configuration tasks. These playbooks can be modified and customized based on your specific requirements.

### Inventory

Update your inventory file (e.g., `inventory.ini` or `inventory.yaml`) to include