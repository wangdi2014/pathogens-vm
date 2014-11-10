pathogens-vm
============

To build a virtual machine with some Sanger pathogens software installed


How to build a new virtual machine
==================================

1. Download the latest version of Bio-Linux
as an OVA file (not an ISO file) from the
[Bio-Linux downloads page](http://environmentalomics.org/bio-linux-download/).
2. Start VirtualBox and choose File -> Import Appliance from the menu
3. Choose the downloaded OVA file from step 1 and click 'Continue'.
4. Click on import, change the Base Memory option to 4096, then click
continue.
5. Click on import and wait for VirtualBox to import the virtual machine.
6. Start the virtual machine.
7. In the virtual machine, run these commands from a terminal
(the root password is 'manager'):
```
    sudo apt-get install -y git
    git clone https://github.com/sanger-pathogens/pathogens-vm.git
    cd pathogens-vm
    ./install.set_appearance.sh
    sudo ./install.sh```
8. Shut down the machine.
9. If you want to check the software that was installed, then restart
the virtual machine and run this in a terminal:
```
    cd pathogens-vm
    ./get_versions.pl all_packages.tsv```
10. Optional: run zero-free to make the final exported OVA file smaller
(see instructions below).
11. Make the OVA file with File -> Export Appliance in the main
VirtualBox menu.
Select the correct virual machine from the list
and click Continue. Rename the file to pathogens-vm.YYYY-MM-DD.ova, with
the correct date. The format should be OVF 1.0. Click Continue, then
change the Name to pathogens-vm YYYY-MM-DD, and click Export.


How to run zero-free
====================

1. Boot the machine. As soon as it starts booting, hold down
the shift key to bring up the GRUB menu, stopping it from
booting as usual into Bio-Linux.
2. Select 'Advanced options for Bio-Linux 8', then
'Bio-Linux 8, with Linux 3.13.0-32-generic (recovery mode)'.
After it boots, choose 'Drop to root shell prompt'.
3. Run these commands:
```
 mount -n -o remount,ro -t ext3 /dev/sda1 /
 zerofree -v /dev/sda1
 shutdown -h now
```
