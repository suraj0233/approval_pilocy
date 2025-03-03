resource "spacelift_mounted_file" "security_team" {
  stack_id      = "*"  # This will mount the file to all stacks
  relative_path = "security_team.rego"
  content       = <<EOT
package spacelift

# Define security team members by their login names
security_team = [
    "suraj.jadhav@zuplon.com"
      
]
EOT
}
