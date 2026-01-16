# Inception

## Table of Contents
- [1. The VM](#1-the-vm)
- [1.1. VM creation](#11-vm-creation)
- [1.3. VM Setup](#13-vm-setup)
	- [1.3.1. Add user as sudo](#131-add-user-as-sudo)

## 1. The VM
### 1.1. VM creation
Download image of Debian https://cdimage.debian.org/cdimage/release/13.3.0/amd64/iso-cd/
What is a netinst image? The netinst CD here is a small CD image that contains just the core Debian installer code and a small core set of text-mode programs (known as "standard" in Debian). To install a desktop or other common software, you'll also need either an Internet connection or some other Debian CD/DVD images.
I chose debian-13.3.0-amd64-netinst.iso
I use Oracle Virtual Box for virtual machine. Manual: https://www.virtualbox.org/manual/ch01.html
Settings: 4GB Memory, 4 processors, Enable EFI. Enables Extensible Firware Interface (EFI) booting for the guest OS; 29GB HardDisk
I enable EFI The Extensible Firmware Interface (EFI), officially known as the Unified Extensible Firmware Interface (UEFI), is a modern software interface that has replaced the traditional BIOS.
VM settings > System: I disable Audio; Display: 128 Mb and Graphic Controller VMSVGA (Use this graphics controller to emulate a VMware SVGA graphics device. This is the default graphics controller for Linux guests.) and Enable 3D Acceleration for better UI responsiveness.; Network is set to NAT - Network Address Translation (NAT) mode. This way the guest can connect to the outside world using the host's networking and the outside world can connect to services on the guest which you choose to make visible outside of the virtual machine.

Installation:
When starting the VM, choose Graphical Install.
A domain name is a human-friendly address, like google.com, that identifies a website on the internet, replacing complex numerical IP addresses (e.g., 192.0.2.2) and acting as a unique, memorable identifier for online services like websites and email.
In the partition menu - Partitioning method: Guided - use entire disk and set up LVM
Only / root
Amount of volume group to use for guided partitioning: 27GB
Software selection: Ssh and GNOME - better lightweigh XFCE is a great choice for virtual machines because it uses very little RAM.

Once inside:
Filesystem Hierarchy Standard (FHS). Standard server practices: var/ tmp/ home/ partitions
create the folder: 
```bash
mkdir -p /home/mpeshko/data/mariadb /home/mpeshko/data/wordpress.
```

### 1.3. VM setup
#### 1.3.1. Add user as Sudo
Docker Permissions: Later in this project, you will likely want to run Docker commands without typing sudo every single time (e.g., just docker-compose up instead of sudo docker-compose up). To do that, mpeshko will need to be part of the docker group.
Security & Best Practice: In a real-world LEMP setup, you never work as "root" directly. It’s too easy to delete a critical system file by mistake. You work as a normal user (mpeshko) and "escalate" to sudo only when needed.
Path Accuracy: Your project requires data to live in /home/mpeshko/data. If you do everything as the root user, you might accidentally create those folders with "root-only" permissions. Then, your WordPress container (running as a non-root user inside the container) might fail to write files to those folders, causing a "Permission Denied" error.
Switch to the Root user:
```bash
su -
```
Add your user to the sudo group:
```bash
usermod -aG sudo mpeshko
```
Install sudo (Just in case):
```bash
apt update && apt install sudo
```
Reboot:
```bash
reboot
```

How to verify if you are already "Good to go":
```bash
groups
```
If you see sudo in the list, you are all set!
In the Settings window, under General, you can configure the most fundamental aspects of the virtual machine such as memory and essential hardware.

Shared Clipboard.  If you want to enable the copy and paste between the VM and your main PC, go to the Device Settings > General -> General. Advanced tab -> Shared Clipboard > Bidirectional. With this option, you can copy and paste text between the VM and your main PC.

Drag and Drop. Remain disabled.
https://www.virtualbox.org/manual/ch04.html

Shared Folder improvement that makes your workflow much smoother.
https://www.virtualbox.org/manual/ch03.html#shared-folders

Without a shared folder, your Virtual Machine (VM) is like a computer in a locked room. If you want to move a file (like a configuration script or a piece of code) from your Ubuntu host to your Debian VM, you would have to use a USB drive, email it to yourself, or use GitHub.
A Shared Folder acts like a "bridge." It creates a folder that exists on both machines at the same time.
Automatic Mounting. If a mount point is not specified: Linux guest. Folders are mounted under the /media directory.

Oracle Manual. Guest Additions https://www.virtualbox.org/manual/ch04.html

VirtualBox Guest Additions are special drivers for your VM. Think of them as the "software" that tells Debian how to talk to the VirtualBox hardware.
The Oracle VM VirtualBox Guest Additions for all supported guest operating systems are provided as a single CD-ROM image file which is called VBoxGuestAdditions.iso. This image file is located in the installation directory of Oracle VM VirtualBox. To install the Guest Additions for a particular VM, you mount this ISO file in your VM as a virtual CD-ROM and install from there.

Instruction:
In your main PC, create a folder in your home directory called shared . This folder will be used to share files between your main PC and the VM.
In the VirtualBox settings > Shared Folders, add a new shared folder with the name shared and the path to the folder “/home/mpeshko/shared” that you created in your main PC and check the auto-mount.
In the menu of the "Instance" (the window where Debian is actually running) - Devices > select insert Guest Additions CD image.
Open the terminal in the CD folder and run the following command
```bash
sudo sh VBoxLinuxAdditions.run
sudo reboot
```
Set up the Permissions: add your user to the vboxsf group and define your user as owner of the shared folder.
```bash
sudo usermod -aG vboxsf your_user
sudo chown -R your_user:users /media/ # Fix permissions for the media folder
sudo reboot
```

Logout and login again to apply the changes. Now, you can see the shared folder in the /media folder as an external device. ls /media You should see a folder starting with sf_ (for example, sf_shared). If you see it, you are officially "connected" to your Ubuntu host!