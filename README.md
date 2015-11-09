pathogens-vm
============

To build a virtual machine with some Sanger pathogens software installed


How to get and use a virtual machine
====================================

This README has instructions for how to build a VM. If you just want
to use one, then please go the
[pathogens-vm site](http://sanger-pathogens.github.io/pathogens-vm)
for instructions and download links.


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
    ./install.user_settings.sh
    sudo ./install.sh
    ```

8. Shut down the machine.
9. If you want to check the software that was installed, then restart
the virtual machine and run this in a terminal:

    ```
    cd pathogens-vm
    ./get_versions.pl all_packages.tsv
    ```

10. Optional: run zero-free to make the final exported OVA file smaller
(see instructions below).
11. Make the OVA file with File -> Export Appliance in the main
VirtualBox menu.
Select the correct virual machine from the list
and click Continue. Rename the file to pathogens-vm.YYYY-MM-DD.ova, with
the correct date. The format should be OVF 1.0. Click Continue, then
change the Name to pathogens-vm YYYY-MM-DD, and click Export.


How to run zero-free and shrink the vdi file
============================================

1. Boot the machine. As soon as it starts booting, hold down
the shift key to bring up the GRUB menu, stopping it from
booting as usual into Bio-Linux.
2. Select 'Advanced options for Bio-Linux 8', then
'Bio-Linux 8, with Linux 3.13.0-32-generic (recovery mode)'.
After it boots, choose 'Drop to root shell prompt'.
3. Check the type of filesystem with `df -T`. It is probably
`ext3` or `ext4`. Put the right one in the command below.
4. Run these commands:

    ```
    mount -n -o remount,ro -t ext3 /dev/sda1 /
    zerofree -v /dev/sda1
    shutdown -h now
    ```

5. On the host machine (assuming a Mac), clone the vdi file,
which makes a compacted new version:

    ```
    VBoxManage clonehd current.vdi clone.vdi
    ```

How to add new software
=======================

1. The software must be available with apt-get or you need
to write a script, which will be run as root, 
that can install the software. If you write a script, put
it in the `Recipes/` directory. The script should put any compiled
code into a new directory called `/usr/local/bioinf-recipes/tool_name/`,
and put (soft links to) executables in `/usr/local/bin/`.

2. If the software has any non-bioinformatics dependencies, such
as packages from apt-get, Perl modules or Python packages, edit
the file `install.sh` to install them.

2. Add a new line to the file `all_packages.tsv`. The format is
five tab-delimited columns:
  * common name of the software. This must have the same
    name as the script put in `Recipes/`
    used to install the software, if applicable.
  * package name, ie the name to be used if apt-get is
    going to be used to install the package.
  * The install method. Values can be: 'none' if
    it comes already installed, 'apt-get' if it is
    be installed using apt-get, 'recipe' if a custom
    script is to be used. Note 'none' is there so that
    the script `get_versions.pl` can report installed 
    version number of software we are interested in, but
    is installed on Bio-Linux already.
  * A command to run that should output the version either
    to stdout or stderr, amongst an arbitrary number of lines.
  * A Perl regular expression that will match the whole line 
    that has the version number, so that the version will be stored in
    the variable `$1`. This regular expression gets
    `^` prepended and `$` appended, so it looks for 
    a complete line that matches.

3. Add a new line to the file `to_install.txt`, with just the
name of the new tool. It must be the same as the common name
(in column 1) of the file `all_packages.tsv`. The software
packages are installed in the order listed in this file.

4. Commit the changes to this github repository, then
build the machine as above.


