<powershell>
# Enable WinRM
Set-ExecutionPolicy Unrestricted -Force
$null = [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlClrProvider")
$config = [Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer]::new()

# Enable HTTPS listener with a self-signed certificate
$config.ConfigureSsl(0, $true, "Default Web Site", "")

# Configure WinRM
$config.ConfigureRemoteManagement(1)
$config.SetRemoteManagementPorts(0, 5986)

# Set up the firewall to allow incoming WinRM connections
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986

# Create a new user account for Ansible
$ansibleUser = "ansible_user"
$ansiblePassword = "SecurePasswordHere"
net user $ansibleUser $ansiblePassword /add

# Add the new user to the local Administrators group
net localgroup "Administrators" $ansibleUser /add

# Enable WinRM access for the new user
$winrmConfig = [Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer]::new()
$winrmConfig.AddRemoteManagementUser($ansibleUser)
</powershell>
