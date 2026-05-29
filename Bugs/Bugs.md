

# Bugs

This file tracks known bugs, their status, affected files and fixes. Use the template below when adding new entries.

| ID | Date       | Status | Description | Affected Files | Fix / Notes |
|----|------------|--------|-------------|----------------|-------------|
| 1  | 2026-05-29 | Fixed  | Terraform VM creation failed: requested OS disk size (30 GB) was smaller than the image OS disk (127 GB) which causes Azure to return a 409 Conflict. | `variables.tf`, `terraform.tfvars.example` | Updated `os_disk_size_gb` default to `127` in `variables.tf` and updated example values. Re-run `terraform plan` and `terraform apply`. |

## How to add a bug

Add a new row to the table above using this template:

| <ID> | <YYYY-MM-DD> | <Open/Fixed/Won't Fix> | Short description | `file1`, `file2` | Explanation of fix or next steps |

Example:

| 2 | 2026-05-30 | Open | Example bug description | `main.tf` | Needs investigation — assign to @owner |

Keep entries brief and include commit or PR references in the "Fix / Notes" column when available.

