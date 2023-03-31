# Define variables
$username = "ansible_nrf"
$password = ConvertTo-SecureString "giTWg#MTLza4if" -AsPlainText -Force
$fullname = "Ansible Administrator"
$description = "Ansible automation"
$groupname = "Administrators"

# Create the user account
New-LocalUser -Name $username -Password $password -FullName $fullname -Description $description -AccountNeverExpires -UserMayNotChangePassword -ErrorAction Stop
Write-Host "User '$username' created"

# Add the user to the Administrators group
Add-LocalGroupMember -Group $groupname -Member $username -ErrorAction Stop

# Output a success message
Write-Host "User '$username' added to local Administrators group."
