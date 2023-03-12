# Define the username and password for the new user
$username = "ansible"
$password = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

# Create the new user account
New-LocalUser -Name $username -Password $password -FullName "Ansible User" -Description "Local user for Ansible automation" -AccountNeverExpires

# Add the user to the local administrators group
Add-LocalGroupMember -Group "Administrators" -Member $username