#!/usr/bin/env bash

sudo apt-get update

echo Install java

sudo -E apt-get --yes --force-yes install openjdk-6-jdk

echo Install R components

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9

sudo -E apt-get --yes --force-yes update

#### install R
sudo -E apt-get --yes --force-yes install r-base-dev

#### install rstudio-server
## http://www.rstudio.com/ide/download/server
sudo -E apt-get --yes --force-yes install gdebi-core
sudo -E apt-get --yes --force-yes install libapparmor1
wget http://download2.rstudio.org/rstudio-server-0.98.977-amd64.deb
sudo gdebi --n rstudio-server-0.98.977-amd64.deb

sudo useradd rstudio
echo "rstudio:rstudio" | sudo chpasswd
sudo mkdir /home/rstudio
sudo chmod -R 0777 /home/rstudio

#### install shiny-server
## http://www.rstudio.com/shiny/server/install-opensource
sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.2.0.359-amd64.deb
sudo gdebi --n shiny-server-1.2.0.359-amd64.deb

## move examples over to server directory
sudo mkdir /srv/shiny-server/examples
sudo cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples
sudo chown -R shiny:shiny /srv/shiny-server/examples

#### install datadr / trelliscope
## system dependencies
sudo -E apt-get --yes --force-yes install libcurl4-openssl-dev
sudo -E apt-get --yes --force-yes install libxml2-dev

sudo su - -c "R -e \"install.packages('rJava', repos='http://cran.rstudio.com/')\""

#### install Rhipe components
wget http://protobuf.googlecode.com/files/protobuf-2.4.1.tar.gz
tar -xzf protobuf-2.4.1.tar.gz
cd protobuf-2.4.1
./configure
sudo make -j4
sudo make install

sudo ldconfig
cd ..

sudo su - -c "R -e \"install.packages('testthat', repos='http://cran.rstudio.com/')\""

#### install Rhipe
wget http://ml.stat.purdue.edu/rhipebin/Rhipe_0.74.0.tar.gz
sudo R CMD INSTALL Rhipe_0.74.0.tar.gz

sudo su - -c "R -e \"install.packages('MASS', repos='http://cran.rstudio.com/')\""
sudo su - -c "R -e \"install.packages('ggplot2', repos='http://cran.rstudio.com/')\""

## devtools
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
## datadr
sudo su - -c "R -e \"options(repos = 'http://cran.rstudio.com/'); library(devtools); install_github('datadr', 'tesseradata')\""
## trelliscope
sudo su - -c "R -e \"options(repos = 'http://cran.rstudio.com/'); library(devtools); install_github('trelliscope', 'tesseradata')\""

sudo rm -rf ~/*

echo Install CDH4

# sudo -E apt-get --yes --force-yes update
sudo -E apt-get --yes --force-yes install curl wget
sudo -E mkdir -p /etc/apt/sources.list.d
sudo -E touch /etc/apt/sources.list.d/cloudera.list

echo "deb [arch=amd64] http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4 contrib" | sudo tee -a /etc/apt/sources.list.d/cloudera.list
echo "deb-src http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh precise-cdh4 contrib" | sudo tee -a /etc/apt/sources.list.d/cloudera.list

curl -s http://archive.cloudera.com/cdh4/ubuntu/precise/amd64/cdh/archive.key > precise.key
sudo -E apt-key add precise.key
sudo -E apt-get --yes --force-yes update
sudo -E apt-get --yes --force-yes install hadoop-0.20-conf-pseudo
dpkg -L hadoop-0.20-conf-pseudo
ls /etc/hadoop/conf.pseudo.mr1

echo Stop all

for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo -E service $x stop ; done
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo -E service $x stop ; done

echo "export JAVA_HOME=/usr/lib/jvm/java-1.6.0-openjdk-amd64" | sudo -E tee -a /etc/default/hadoop

echo Format namenode

sudo -E -u hdfs hdfs namenode -format

echo Start HDFS

for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo -E service $x start ; done

sudo -E -u hdfs hadoop fs -mkdir /tmp
sudo -E -u hdfs hadoop fs -chmod -R 1777 /tmp

sudo -E -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -E -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -E -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred

sudo -E -u hdfs hadoop fs -ls -R /

sudo -E -u hdfs hadoop fs -mkdir /user/hdfs 
sudo -E -u hdfs hadoop fs -chown hdfs /user/hdfs

sudo -u hdfs hadoop fs -mkdir -p /user/vagrant
sudo -u hdfs hadoop fs -chown vagrant /user/vagrant

export HADOOP=/usr/lib/hadoop
export HADOOP_HOME=/usr/lib/hadoop
export HADOOP_BIN=$HADOOP/bin
export HADOOP_LIBS=`hadoop classpath | tr -d '*'`
export HADOOP_CONF_DIR=/etc/hadoop/conf

sudo echo export HADOOP=$HADOOP | sudo tee -a /etc/profile
sudo echo export HADOOP_HOME=$HADOOP_HOME | sudo tee -a /etc/profile
sudo echo export HADOOP_BIN=$HADOOP_BIN | sudo tee -a /etc/profile
sudo echo export HADOOP_LIBS=$HADOOP_LIBS | sudo tee -a /etc/profile
sudo echo export HADOOP_CONF_DIR=$HADOOP_CONF_DIR | sudo tee -a /etc/profile

sudo touch /home/vagrant/.Renviron
sudo tee -a /home/vagrant/.Renviron <<EOF
HADOOP_CONF_DIR=/etc/hadoop/conf
HADOOP_LIBS=/etc/hadoop/conf:/usr/lib/hadoop/lib/:/usr/lib/hadoop/.//:/usr/lib/hadoop-hdfs/./:/usr/lib/hadoop-hdfs/lib/:/usr/lib/hadoop-hdfs/.//:/usr/lib/hadoop-yarn/.//:/usr/lib/hadoop-0.20-mapreduce/./:/usr/lib/hadoop-0.20-mapreduce/lib/:/usr/lib/hadoop-0.20-mapreduce/.//
HADOOP_BIN=/usr/lib/hadoop/bin
HADOOP_HOME=/usr/lib/hadoop
EOF

echo Start MapReduce

for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo -E service $x start ; done
