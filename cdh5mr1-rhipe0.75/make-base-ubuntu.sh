#!/bin/bash

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9

sudo -E apt-get --yes --force-yes update

#### install R
sudo -E apt-get --yes --force-yes install r-base-dev

#### install rstudio-server
## http://www.rstudio.com/ide/download/server
sudo -E apt-get --yes --force-yes install gdebi-core
sudo -E apt-get --yes --force-yes install libapparmor1
wget http://download2.rstudio.org/rstudio-server-0.98.501-amd64.deb
sudo gdebi --n rstudio-server-0.98.501-amd64.deb
## only want to start manually (as it will be installed in each node)
# echo "manual" | sudo tee /etc/init/rstudio-server.override

sudo useradd rstudio
echo "rstudio:rstudio" | sudo chpasswd
sudo mkdir /home/rstudio
sudo chmod -R 0777 /home/rstudio

#### install shiny-server
## http://www.rstudio.com/shiny/server/install-opensource
sudo su - -c "R -e \"install.packages('shiny', repos='http://cran.rstudio.com/')\""
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.0.0.42-amd64.deb
sudo gdebi --n shiny-server-1.0.0.42-amd64.deb
## only want to start manually (as it will be installed in each node)
# echo "manual" | sudo tee /etc/init/shiny-server.override

## move examples over to server directory
sudo mkdir /srv/shiny-server/examples
sudo cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples
sudo chown -R shiny:shiny /srv/shiny-server/examples

#### install datadr / trelliscope
## system dependencies
sudo -E apt-get --yes --force-yes install libcurl4-openssl-dev
sudo -E apt-get --yes --force-yes install libxml2-dev
sudo -E apt-get --yes --force-yes install mongodb
sudo -E apt-get --yes --force-yes install openjdk-6-jdk

sudo su - -c "R -e \"install.packages('rJava', repos='http://cran.rstudio.com/')\""

#### install Rhipe components
wget http://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz
tar -xzf protobuf-2.5.0.tar.gz
cd protobuf-2.5.0
./configure
sudo make -j4
sudo make install

sudo ldconfig
cd ..

#### install Rhipe
wget http://ml.stat.purdue.edu/rhipebin/Rhipe_0.75.0_cdh5mr1.tar.gz
sudo R CMD INSTALL Rhipe_0.75.0_cdh5mr1.tar.gz

## devtools
sudo su - -c "R -e \"install.packages('devtools', repos='http://cran.rstudio.com/')\""
## datadr
sudo su - -c "R -e \"options(repos = 'http://cran.rstudio.com/'); library(devtools); install_github('datadr', 'tesseradata')\""
## trelliscope
sudo su - -c "R -e \"options(repos = 'http://cran.rstudio.com/'); library(devtools); install_github('trelliscope', 'tesseradata')\""

#### git
sudo -E apt-get --yes --force-yes install git

sudo rm -rf ~/*


#### java environment variables from javareconf
export JAVA_CPPFLAGS=-I/usr/lib/jvm/java-6-openjdk-amd64/jre/../include
export JAVAC=/usr/bin/javac
export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/jre
export JAVAH=/usr/bin/javah
export JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java-6-openjdk-amd64/jre/lib/amd64/server
export JAVA_LIBS=-L/usr/lib/jvm/java-6-openjdk-amd64/jre/lib/amd64/server
export JAVA=/usr/bin/java

### these are wrong for java 1.7
sudo echo 'export JAVA_CPPFLAGS=-I/usr/lib/jvm/java-6-openjdk-amd64/jre/../include' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVAC=/usr/bin/javac' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/jre' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVAH=/usr/bin/javah' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java-6-openjdk-amd64/jre/lib/amd64/server' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVA_LIBS=-L/usr/lib/jvm/java-6-openjdk-amd64/jre/lib/amd64/server' | sudo tee -a /etc/bash.bashrc
sudo echo 'export JAVA=/usr/bin/java' | sudo tee -a /etc/bash.bashrc


#### install cdh5mr1
wget http://archive.cloudera.com/cdh5/one-click-install/precise/amd64/cdh5-repository_1.0_all.deb
sudo dpkg -i cdh5-repository_1.0_all.deb
curl -s http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key | sudo apt-key add -
sudo apt-get  --yes --force-yes update 
sudo apt-get  --yes --force-yes install hadoop-0.20-conf-pseudo
sudo -u hdfs hdfs namenode -format
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done
sudo -u hdfs hadoop fs -mkdir -p /tmp 
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chmod 1777 /var/lib/hadoop-hdfs/cache/mapred/mapred/staging
sudo -u hdfs hadoop fs -chown -R mapred /var/lib/hadoop-hdfs/cache/mapred
for x in `cd /etc/init.d ; ls hadoop-0.20-mapreduce-*` ; do sudo service $x start ; done
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

echo "HADOOP_CONF_DIR=/etc/hadoop/conf
HADOOP_LIBS=/etc/hadoop/conf:/usr/lib/hadoop/lib/:/usr/lib/hadoop/.//:/usr/lib/hadoop-hdfs/./:/usr/lib/hadoop-hdfs/lib/:/usr/lib/hadoop-hdfs/.//:/usr/lib/hadoop-yarn/.//:/usr/lib/hadoop-0.20-mapreduce/./:/usr/lib/hadoop-0.20-mapreduce/lib/:/usr/lib/hadoop-0.20-mapreduce/.//
HADOOP_BIN=/usr/lib/hadoop/bin
HADOOP_HOME=/usr/lib/hadoop" | tee ~/.Renviron
