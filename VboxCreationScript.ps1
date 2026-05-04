# Configuration - Adjust paths to your local VDI files
$ExistingVMs = VBoxManage list vms
$VM_TARGET_NAME = "Redis_Target"
$VM_KALI_NAME = "Kali_Attacker"
$VDI_TARGET_PATH = "C:\Users\wille\CyberSecVirt\VDI's\64bit\Ubuntu_20.04.4.vdi"
$VDI_KALI_PATH = "/path/to/your/kali.vdi"
$ISO_GUEST_ADDITIONS = "/usr/share/virtualbox/VBoxGuestAdditions.iso"
$USER = "osboxes"
$PASS = "osboxes.org"
$SETUP_SCRIPT = "C:\Users\wille\CyberSecVirt\CyberSecurity_NPE\setup\setup_redis.sh"

if ($ExistingVMs -match "`"$VM_TARGET_NAME`"") {
    Write-Host "$VM_TARGET_NAME bestaat al"
} else {
    # Create the Target VM
    VBoxManage createvm --name "$VM_TARGET_NAME" --ostype "Ubuntu_64" --register --groups=/NPE

    # Set system resources (RAM and CPUs)
    VBoxManage modifyvm "$VM_TARGET_NAME" --memory 2048 --cpus 2 --vram 32

    # Add a SATA Controller
    VBoxManage storagectl "$VM_TARGET_NAME" --name "SATA Controller" --add sata --controller IntelAhci

    # Attach the downloaded VDI file
    VBoxManage storageattach "$VM_TARGET_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_TARGET_PATH"

    # Setup Network Adapters: NAT and Host-only
    VBoxManage modifyvm "$VM_TARGET_NAME" --nic1 nat
    VBoxManage modifyvm "$VM_TARGET_NAME" --nic2 hostonly --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
}

# Start the vm
VBoxManage startvm "$VM_TARGET_NAME" --type gui

Start-Sleep -Seconds 60

# Wait for guest additions (UNCOMMENTED AND RE-ENABLED)
# Write-Host "Waiting for Guest Additions to become active..."
#$ready = $false
#while (-not $ready) {
#    # Check if the Guest Additions service is reporting a version
#    $check = VBoxManage guestproperty get "$VM_TARGET_NAME" "/VirtualBox/GuestAdd/VBoxService/Version"
#    if ($check -match "Value: ") {
#        $ready = $true
#        Write-Host "Guest Additions are LIVE!"
#    } else {
#        Write-Host "Still booting... (checking again in 5s)"
#        
#    }
#}

# Now it is safe to run your copyto and run commands
Write-Host "Proceeding with Redis installation..."

# Copy the setup script from your Windows host to the VM's /tmp folder
VBoxManage guestcontrol "$VM_TARGET_NAME" copyto --username $USER --password $PASS "$SETUP_SCRIPT" "/tmp/setup_redis.sh"

# Execute the script inside the VM
VBoxManage guestcontrol "$VM_TARGET_NAME" run --username $USER --password $PASS --exe "/bin/bash" -- "/tmp/setup_redis.sh"