# CyberSecurity_NPE

In this github repository we are setting up a vulnerable redis database and then trying to attack it using a kali VM.

# Creators
[GH_Tibo_Willemsen](https://github.com/Tibo-Willemsen)
[GH_Alizée_Vander_Henst](https://github.com/alizeevdh)

# Walkthrough 

## Step 1: Download ubuntu 20.04
First you need to download an ubuntu 20.04 VDI. This is because this os still has the vulnerable LUA directories. You can download this from this link: https://sourceforge.net/projects/osboxes/files/v/vb/55-U-u/20.04/20.04.4/64bit.7z/download. 

## Step 2: Extract Ubuntu_20.04.4.vdi
When you download from the link that we placed above here, you will have a zip file downloaded containing the VDI file that we need. You need to extract this .VDI file to a place you remember and then also change the variable in [VboxCreationScript.ps1](VboxCreationScript.ps1). This will be the variable: $VDI_TARGET_PATH.

## Step 3: Run VboxCreationScript.ps1
Now you can run the script [VboxCreationScript.ps1](VboxCreationScript.ps1).

## Variables
Voor Tibo: $VDI_TARGET_PATH = "C:\Users\wille\CyberSecVirt\VDI's\64bit\Ubuntu_20.04.4.vdi"
Voor Alizee: 