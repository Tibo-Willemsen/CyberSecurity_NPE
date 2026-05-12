# Variables
$ExistingVMs = VBoxManage list vms
$VM_TARGET_NAME = "Redis_Target"
$VM_KALI_NAME = "Kali_Attacker"
$VDI_TARGET_PATH = "C:\Users\alize\Documents\NPE\Ubuntu_20.04.4.vdi"
$VDI_KALI_PATH = "C:\Users\alize\Documents\NPE\kali-linux-2026.1-virtualbox-amd64.vdi"
$TARGET_USER = "osboxes"
$TARGET_PASS = "osboxes.org"
$KALI_USER = "kali"
$KALI_PASS = "kali"
$SETUP_SCRIPT = "C:\Users\alize\Documents\CyberSecurity_NPE\setup\setup_redis.sh"


Write-Host "Starten met de installaties van de VMs"
Write-Host "Verwerken van $VM_TARGET_NAME"
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
    Write-Host "de installatie $VM_TARGET_NAME was succesvol"
}

Write-Host "Verwerken van $VM_KALI_NAME"
if ($ExistingVMs -match "`"$VM_KALI_NAME`"") {
    Write-Host "$VM_KALI_NAME bestaat al"
} else {
    # Create the Target VM
    VBoxManage createvm --name "$VM_KALI_NAME" --ostype "Debian_64" --register --groups=/NPE

    # Set system resources (RAM and CPUs)
    VBoxManage modifyvm "$VM_KALI_NAME" --memory 2048 --cpus 2 --vram 32

    # Add a SATA Controller
    VBoxManage storagectl "$VM_KALI_NAME" --name "SATA Controller" --add sata --controller IntelAhci

    # Attach the downloaded VDI file
    VBoxManage storageattach "$VM_KALI_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_KALI_PATH"

    # Setup Network Adapters: NAT and Host-only
    VBoxManage modifyvm "$VM_KALI_NAME" --nic1 nat
    VBoxManage modifyvm "$VM_KALI_NAME" --nic2 hostonly --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
    Write-Host "de installatie $VM_KALI_NAME was succesvol"
}

# Start de vms en wacht tot ze reageren
Write-Host "Opstarten van de VMs en wachten tot ze reageren"
$MaxRetries = 30
$RetryCount = 0
$IsReady = $false
while (-not $IsReady -and $RetryCount -le $MaxRetries) {
    $TestCmd = VBoxManage guestcontrol "$VM_TARGET_NAME" run --username $TARGET_USER --password $TARGET_PASS --exe "/usr/bin/whoami" 2>$null

    if ($TestCmd -match $TARGET_USER) {
        $IsReady = $true
        Write-Host "Handshake successvol! $VM_TARGET_NAME is klaar"
    } else {
        if ($retryCount -eq 0) {
            Write-Host "Opstarten van $VM_TARGET_NAME"
            VBoxManage startvm "$VM_TARGET_NAME" --type gui
            $RetryCount++
            Write-Host "Wachten tot $VM_TARGET_NAME reageert..."
        }
        else {
            Write-Host "$VM_TARGET_NAME is nog niet klaar (Poging: $RetryCount/$MaxRetries). Wacht 5s..."
            Start-Sleep -Seconds 5
            $RetryCount++
        }
    }
}

if (-not $IsReady) {
    Write-Error "$VM_TARGET_NAME reageert niet binnen de timeout periode."
    exit
}

$MaxRetries = 30
$RetryCount = 0
$IsReady = $false
while (-not $IsReady -and $RetryCount -le $MaxRetries) {
    $TestCmd = VBoxManage guestcontrol "$VM_KALI_NAME" run --username $KALI_USER --password $KALI_PASS --exe "/usr/bin/whoami" 2>$null

    if ($TestCmd -match $KALI_USER) {
        $IsReady = $true
        Write-Host "Handshake successvol! $VM_KALI_NAME is klaar"
    } else {
        if ($retryCount -eq 0) {
            Write-Host "Opstarten van $VM_KALI_NAME"
            VBoxManage startvm "$VM_KALI_NAME" --type gui
            $RetryCount++
            Write-Host "Wachten tot $VM_KALI_NAME reageert..."
        }
        else {
            Write-Host "$VM_KALI_NAME is nog niet klaar (Poging: $RetryCount/$MaxRetries). Wacht 5s..."
            Start-Sleep -Seconds 5
            $RetryCount++
        }
    }
}

if (-not $IsReady) {
    Write-Error "$VM_KALI_NAME reageert niet binnen de timeout periode."
    exit
}

# Now it is safe to run your copyto and run commands
Write-Host "Doorgaan met de Redis installatie..."

# Copy the setup script from your Windows host to the VM's /tmp folder
VBoxManage guestcontrol "$VM_TARGET_NAME" copyto --username $TARGET_USER --password $TARGET_PASS "$SETUP_SCRIPT" "/tmp/setup_redis.sh"

# Execute the script inside the VM
VBoxManage guestcontrol "$VM_TARGET_NAME" run --username $TARGET_USER --password $TARGET_PASS --exe "/bin/bash" -- "/tmp/setup_redis.sh"