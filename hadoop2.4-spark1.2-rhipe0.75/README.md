

# Tessera hadoop2.4-spark1.2-rhipe0.75

This directory provides Vagrant installation scripts for a Tessera environment with Hadoop 2.4 (YARN) / Spark 1.2 / Rhipe 0.75.  For instructions on how to set this environment up, see [here](https://github.com/tesseradata/install-vagrant).

## Notes ##

### Web UIs ###

Some ports are forwarded, making some web UIs available:

* http://localhost:9787: rstudio server
* http://localhost:4838: shiny server
* http://localhost:9088: hadoop applications
* http://localhost:60070: hadoop data node
* http://localhost:60075: hadoop data node
* http://localhost:9080: spark master
* http://localhost:5040: spark jobs

### Starting and Stopping Services ###

Once the machine is provisioned, all services should be running.  For this VM, all services are run by the `vagrant` user.  The services continue to run after bringing up a suspended VM as well.  But you may still find yourself needing to manually start or stop a service.

Starting:

```
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh
export SPARK_HOME=/home/vagrant/hadoop/spark-1.2.0-bin-hadoop2.4
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-slave.sh 1 spark://precise64:7077
```

Stopping:

```
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh stop historyserver
$HADOOP_HOME/sbin/stop-yarn.sh
$HADOOP_HOME/sbin/stop-dfs.sh
$SPARK_HOME/sbin/stop-slaves.sh
$SPARK_HOME/sbin/stop-master.sh
```

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

