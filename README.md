# CyberSecurity_NPE

In this github repository we are setting up a vulnerable redis database and then trying to attack it using a kali VM.

# Creators
[GH_Tibo_Willemsen](https://github.com/Tibo-Willemsen)
[GH_Alizée_Vander_Henst](https://github.com/alizeevdh)

# Walkthrough 

## Step 1: Download ubuntu 20.04 and kali VDI
First you need to download an ubuntu 20.04 and a kali VDI. You will need this version of ubuntu because it still contains the vulnerable LUA directories. You can download the ubuntu VDI from this link: https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/20.04/20.04.4/64bit.7z/download and the kali VDI from this link: https://www.kali.org/get-kali/#kali-virtual-machines

## Step 2: Extract Ubuntu_20.04.4.vdi
When you downloaded the VDIs from the links above, you will have 2 zip files downloaded containing the VDI files that we need. You need to extract these .VDI files to a place you can remember and then also change the variables in [VboxCreationScript.ps1](VboxCreationScript.ps1) to the correct locations on your device. The variables you need to change are: $SETUP_SCRIPT, $VDI_TARGET_PATH and $VDI_KALI_PATH.

## Step 3: Run VboxCreationScript.ps1
Now you can run the script: [VboxCreationScript.ps1](VboxCreationScript.ps1).

## Variables
Voor Tibo: 
    - $SETUP_SCRIPT = "C:\Users\wille\CyberSecVirt\CyberSecurity_NPE\setup\setup_redis.sh"
    - $VDI_TARGET_PATH = "C:\Users\wille\CyberSecVirt\VDI's\64bit\Ubuntu_20.04.4.vdi"
    - $VDI_KALI_PATH = "C:\Users\wille\CyberSecVirt\VDI's\kali-linux-2026.1-virtualbox-amd64\kali-linux-2026.1-virtualbox-amd64.vdi"

Voor Alizee: 

## Verduidelijking
In onze setup_redis.sh hebben wij een lijn die zegt: "echo "$PASSWORD" | sudo -S sed -i "s/protected-mode yes/protected-mode no/" /etc/redis/redis.conf". Dit zal de protectie modus van redis afzetten. Dit is de bedoeling en is de vulnerability. Wat we proberen simuleren is een luie en slechte admin die dit om off zet om andere devices makkelijker access te geven aan deze service. Dit kmt omdat als het aan staat, dan accepteert redis enkel connecties die van de local host komen.