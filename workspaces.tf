
# Register the AWS Directory with WorkSpaces
resource "aws_workspaces_directory" "my_workspace_directory" {
  directory_id = aws_directory_service_directory.my_directory.id
}

# Create a performance Windows Workspace
resource "aws_workspaces_workspace" "my_workspace" {

  count = 0

  bundle_id    = "wsb-b9jc2fhhl"
  directory_id = aws_directory_service_directory.my_directory.id
  user_name    = "nrf"

  workspace_properties {
    compute_type_name                         = "PERFORMANCE"
    user_volume_size_gib                      = 10
    root_volume_size_gib                      = 80
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}
