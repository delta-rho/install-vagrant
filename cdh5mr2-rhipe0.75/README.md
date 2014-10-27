

# Tessera cdh5mr2-rhipe0.75

This directory provides Vagrant installation scripts for a Tessera environment with CDH5mr2 / Rhipe 0.75.  For instructions on how to set this environment up, see [here](https://github.com/tesseradata/install-vagrant).

## Notes ##

### Vagrant reboot ###

For yet unknown reasons, you need to halt and restart your vagrant VM to get Hadoop to work.  So in addition to your initial `vagrant up`, you need to also do

```
vagrant halt
vagrant up 
```

### Hadoop URLs ###

Note that since this is mr2, the URLs for Hadoop services are a bit different:

* NameNode: `http://localhost:60070`
* DataNode: `http://localhost:60075`
* Applications: `http://localhost:9088`

## Troubleshooting ##

### (403) Forbidden ###

If during `vagrant up` you get an error like the following:

```
==> default: > options(unzip = 'unzip', repos = 'http://cran.rstudio.com/'); library(devtools); install_github('tesseradata/trelliscope')
==> default: Downloading github repo tesseradata/trelliscope@master
==> default: Error in download(dest, src, auth) : client error: (403) Forbidden
==> default: Calls: install_github ... remote_download.github_remote -> download -> <Anonymous>
==> default: Execution halted
The SSH command responded with a non-zero exit status. Vagrant
assumes that this means the command failed. The output for this command
should be in the log above. Please read the output to determine what
went wrong.
```

It means you have been rate limited by github for too many API calls.  For example, on a command line, try the following to get details:

```
curl -i https://api.github.com/tesseradata/trelliscope
```

### RHIPE job will not leave PREP phase ###

See the notes above.  Basically, you need to do the following:

```
vagrant halt
vagrant up 
```
