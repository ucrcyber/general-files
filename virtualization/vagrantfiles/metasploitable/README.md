# Kali + Metasploitable Practice Environment for CCDC

## Outcomes

To set up a virtual machine environment on team members' laptops so that they can
test offensive techniques against a vulnerable system in an isolated environment.

This should allow them to:

* Observe how these offensive techniques show up in log files, so that they can identify this in the future.
* Observe what an exploit looks like from the attacker's point of view, and how exploits against part 
  of a system are leveraged into additional access to that system.
* Observe techniques for persistence and what these look like to both the defender and attacker on a system level.

The virtual machine environment itself has these capabilities:

* Works on Windows, Linux, and Mac.
* All VMs can be reset to their base state quickly, either with 'vagrant destroy; vagrant up', or with use of snapshots.
* VMs within the environment can communicate with each other.  One of the two VMs (Kali) is the platform for attacks,
  the other (Metasploitable) is the target.

## Requirements:

Laptop with:
 * 64 bit architecture
 * 4G+ of RAM.  More RAM will make working with VMs faster.
 * Virtualization enabled in the BIOS.
 * Enough hard drive space.  An SSD will definitely make working with VMs faster.
 
## Setup

Setup involves these steps regardless of what operating system is involved:

* Install VirtualBox, as the virtualization software.
* Install Vagrant, as the software used to manage the virtual machines.
* Install Git, to be able to access the repositories containing the descriptions of the virtual machines.


###Installation on Windows

(1) Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads
Make sure to install the new drivers and services when prompted, in order to be able to make use of virtualized hardware.

(2) Download and install Vagrant from https://www.vagrantup.com/downoads.html
Choose amd64 in order to be able to run 64 bit VMs. The installer is click through. You need to restart your system at the end.

(3) Download and install MobaXterm from http://mobaxterm.mobatek.net/download.html
Select "Home Edition (Installer edition)", and download it as a file.  The installer is click through.

(4) Open MobaXterm from the icon on your desktop, or from the Start menu.
Allow MobaXterm to access local networks.

Click on Start Local Terminal
Go to "Tools" -> "MobaApt packages manager (experimental)"
Search for and install git. The install will take a few minutes.  
You can verify it is installed by typing ```git``` in the terminal.

(5) Enable Vagrant ssh (this is a bug workaround)

(a) Edit the .bashrc for MobaXterm in the terminal.
```
vim .bashrc
```

(b) Add this line, save, and exit:
```
export PATH=/drives/c/HashiCorp/Vagrant/bin:${HOME}/bin:${PATH}
```

(c) Run the following shell commands to set up the version of SSH that vagrant can use.
```
mkdir ~/bin
cp -av /bin/_ssh.exe ~/bin/ssh.exe
```

(6) Open another terminal using the + sign next to your current terminal, and test that /drives/c/HashiCorp/Vagrant/bin was added to your path
```
echo $PATH
```

###Installation on OS X

(1) Download and install VirtualBox from https://www.virtualbox.org/wiki/Downloads

(2) Download and install Vagrant from https://www.vagrantup.com/downoads.html

(3) Follow the instructions for installing MacPorts here: https://www.macports.org/install.php
Note that this also involves installing Xcode *before* you can do other steps!

(4) Use MacPorts to install git.
```
sudo port install git
```

###Installation on Linux

(1) Install VirtualBox.  Most likely using your distribution's package manager.

(2) Install Vagrant, from https://www.vagrantup.com/downoads.html.  The version provided by your distribution is most likely out of date...

(3) Install Git.  Most likely using your distribution's package manager.


##Test Configuration (on all operating systems)

(1) Make a directory, change directory into it, and make your first virtual machine

```
mkdir testvm
cd testvm
vagrant init ubuntu/trusty64
```

This creates a Vagrantfile in the current directory.  Vagrantfiles contain descriptions of the virtual machines in your environment, and the configuration
of those virtual machines and any hypervisors like VirtualBox that you are using.


(2) Edit that file and modify it so that the code related to setting up a gui interface is uncommented (look for vb.gui).

(3) Start Vagrant.  The first time you do so, it will download the VM remotely, and this will take several minutes.  The second and further times 
that you do so, it will already have a local copy of the VM, so this step will be skipped. 
```
vagrant up
```

(4) Experiment with the VM: see what these commands do:

```
vagrant ssh
  exit # run in VM, after you are done testing
vagrant status
vagrant halt
vagrant status
vagrant up
vagrant destroy
vagrant status
vagrant plugin install sahara
vagrant sandbox on
vagrant ssh
  sudo apt-get update # run in VM
  sudo apt-get upgrade # run in VM
vagrant sandbox revert 
vagrant ssh
  sudo apt-get update # run in VM
  sudo apt-get upgrade # run in VM
vagrant sandbox commit
vagrant ssh
  sudo apt-get update # run in VM
  sudo apt-get upgrade # run in VM
vagrant sanbox off
vagrant halt
```
##Kali and Metasploitable

###Initial Setup

Use the ```Vagrantfile``` in the repository.  It contains descriptions of where to get Kali 2 and Metasploitable Vagrant boxes.  These are custom built with Packer because there do not appear to be official Vagrant boxes for either setup.

Type ```vagrant up``` in the directory containing the ```Vagrantfile```.  This will download and start both VMs.  Specficic details:

* Both have IP addresses on a NAT network, so that Kali can access Metasploitable.  The IPs are 172.21.0.2 (Kali) and 172.21.0.3 (Metasploitable).  ONLY USE THESE IPS WHEN ACCESSING THE VMS.  You _REALLY_ do not want any traffic from your Kali VM being targeted at any other IPs, under any circumstances.

### GUI access

In this iteration, both start without a GUI.  This is standard for most UNIX systems.  If you do want a GUI:
* Metasploitable: 
  * Log in as msfadmin/msfadmin and run

    ```
    sudo rm -vf /tmp/.x0-lock
    startx
    ```

* Kali:
  * Log in as vagrant/vagrant and run

    ```
    sudo apt-get install kali-defaults kali-root-login desktop-base xfce4 xfce4-places-plugin xfce4-goodies
    startx
    ```

### Tutorial

There is a tutorial on exploiting Metasploitable at https://community.rapid7.com/docs/DOC-1875.  The environment you used in the qualifier wasn't as badly configured and already exploited as Metasploitable, but it did have some of the same characteristics, and Metasploitable also shows a range of problems that other teams have encountered over time, such as issues with rlogin and vulnerable web applications (including phpMyAdmin and also a webapp that is *specifically designed* to be vulnerable..  Some notes:

* Make SURE you use the IPs identified in the Vagrantfile and in the documentation above, NOT the IPs in the tutorial.

