terraform {
  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.0" # Use the latest compatible version
    }
  }
}

resource "spacelift_policy" "iam_security_approval" {
  name = "require-security-approval-for-iam"
  body = <<EOT
package spacelift

# Track if there are any IAM policy changes
has_iam_policy_changes {
    input.proposed_state[_].type == "aws_iam_policy"
}

# Require approval from security team members
security_team_approved {
    some approval in input.approvals
    approval.state == "approved"
    approval.login in data.spacelift.security_team
}

# Main deny rule
deny[msg] {
    has_iam_policy_changes
    not security_team_approved
    msg := "Changes to IAM policies require approval from the security team"
}

# Track proposed changes
track[msg] {
    has_iam_policy_changes
    msg := "This change includes modifications to IAM policies"
}
EOT

  type = "PLAN"
}

# Define the security team members
resource "spacelift_policy_attachment" "security_team" {
  policy_id = spacelift_policy.iam_security_approval.id
  stack_id  = "*"  # This will attach the policy to all stacks
}
