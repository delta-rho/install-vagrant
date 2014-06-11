
# Tessera with Vagrant #

Vagrant provides a lightweight mechanism to provision a reproducible portable Tessera environment for testing and development.  This is the easiest way to get a local platform-independent single-node VM with the Hadoop-backed Tessera environment installed.

## Provisioning a VM ##
*****

Download and install Vagrant: http://www.vagrantup.com/downloads.html

On a command line, clone this repository:

````
git clone https://github.com/tesseradata/install-vagrant
````

Choose the directory in this repository with the environment you would like, for example

````
cd install-vagrant/cdh5mr1-rhipe0.75
````

This will put you in an environment with CDH5 running MapReduce version 1 and with RHIPE 0.75.

To provision the environment, simply type the following:

````
vagrant up
````

Once the provisioning has completed

* To work from command line: SSH into the machine with `vagrant ssh`
* To work from RStudio IDE: navigate to 'localhost:9787' in your web browser with credentials vagrant:vagrant

