
# Register the AWS Directory with WorkSpaces
resource "aws_workspaces_directory" "my_workspace_directory" {
  directory_id = aws_directory_service_directory.my_directory.id


  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = false
    restart_workspace    = true
    switch_running_mode  = false
  }

  workspace_creation_properties {
    custom_security_group_id            = aws_security_group.workspaces_access.id
    enable_internet_access              = true
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = false
  }
}

# Create a performance Windows Workspace
resource "aws_workspaces_workspace" "my_workspace" {

  count = 1

  bundle_id    = "wsb-b9jc2fhhl"
  directory_id = aws_directory_service_directory.my_directory.id
  user_name    = "Admin"

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

  depends_on = [aws_workspaces_directory.my_workspace_directory]

}
