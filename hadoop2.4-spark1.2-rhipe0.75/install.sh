# install hadoop

## passwordless ssh
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
# to get around (yes/no) that will come later
ssh -oStrictHostKeyChecking=no localhost exit
ssh -oStrictHostKeyChecking=no 127.0.0.1 exit
ssh -oStrictHostKeyChecking=no 0.0.0.0 exit
ssh -oStrictHostKeyChecking=no precise64 exit

## misc dependencies
sudo apt-get update -q -q
sudo apt-get install -y vim curl git ant maven pkg-config

## java
sudo apt-get install -y openjdk-7-jdk

mkdir /home/vagrant/hadoop
cd /home/vagrant/hadoop

wget http://archive.apache.org/dist/hadoop/core/hadoop-2.4.0/hadoop-2.4.0.tar.gz
tar -xzf hadoop-2.4.0.tar.gz
cd hadoop-2.4.0

cp /home/vagrant/conf/* /home/vagrant/hadoop/hadoop-2.4.0/etc/hadoop/

export HADOOP_HOME=/home/vagrant/hadoop/hadoop-2.4.0
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
export HADOOP_LIBS=`$HADOOP_HOME/bin/hadoop classpath | tr -d '*'`

touch /home/vagrant/.Renviron
echo "HADOOP=$HADOOP_HOME" | tee -a /home/vagrant/.Renviron
echo "HADOOP_HOME=$HADOOP_HOME" | tee -a /home/vagrant/.Renviron
echo "HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" | tee -a /home/vagrant/.Renviron
echo "HADOOP_BIN=$HADOOP_HOME/bin" | tee -a /home/vagrant/.Renviron
echo "HADOOP_LIBS=$HADOOP_LIBS" | tee -a /home/vagrant/.Renviron
echo 'LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' | tee -a /home/vagrant/.Renviron
echo 'HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' |  tee -a /home/vagrant/.Renviron
echo 'JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' | tee -a /home/vagrant/.Renviron
echo 'RHIPE_RUNNER=/home/vagrant/rhRunner.sh' | tee -a /home/vagrant/.Renviron
echo export "HADOOP=$HADOOP_HOME" | sudo tee -a /etc/profile
echo export "HADOOP_HOME=$HADOOP_HOME" | sudo tee -a /etc/profile
echo export "HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop" | sudo tee -a /etc/profile
echo export "HADOOP_BIN=$HADOOP_HOME/bin" | sudo tee -a /etc/profile
echo export 'PATH=$PATH:$HADOOP_BIN' | sudo tee -a /etc/profile
echo export "HADOOP_LIBS=$HADOOP_LIBS" | sudo tee -a /etc/profile
echo export 'LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH' | sudo tee -a /etc/profile
echo export 'HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' | sudo tee -a /etc/profile
echo export 'JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64' | sudo tee -a /etc/profile
echo export 'RHIPE_RUNNER=/home/vagrant/rhRunner.sh' | sudo tee -a /etc/profile

source /etc/profile

hdfs namenode -format

$HADOOP_HOME/sbin/start-dfs.sh
# http://localhost:60070/

hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
hadoop fs -chmod -R 1777 /tmp
hadoop fs -mkdir -p /var/log/hadoop-yarn
hadoop fs -mkdir -p /user/vagrant
hadoop fs -chown vagrant:vagrant /user/vagrant

$HADOOP_HOME/sbin/start-yarn.sh
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver --config $HADOOP_CONF_DIR

## R
sudo apt-get -y install unzip libcairo2-dev libcurl4-openssl-dev screen libssl0.9.8 gdebi-core firefox libapparmor1 psmisc

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
sudo apt-get -y update
sudo apt-get install -y r-base-dev
sudo chmod -R aou=rwx /usr/local/lib/R/site-library

sudo -E R CMD javareconf

## rJava package
R -e "install.packages('rJava', repos='http://www.rforge.net/')"

## protobuf
export PROTO_BUF_VERSION=2.5.0
wget https://protobuf.googlecode.com/files/protobuf-$PROTO_BUF_VERSION.tar.bz2
tar jxvf protobuf-$PROTO_BUF_VERSION.tar.bz2
cd protobuf-$PROTO_BUF_VERSION
./configure && make -j4
sudo make install
cd ..

## RHIPE
export PKG_CONFIG_PATH=/usr/local/lib
wget http://ml.stat.purdue.edu/rhipebin/Rhipe_0.75.1.4_hadoop-2.tar.gz
R CMD INSTALL Rhipe_0.75.1.4_hadoop-2.tar.gz

echo "export LD_LIBRARY_PATH=/usr/local/lib" | tee -a /home/vagrant/rhRunner.sh
echo "exec /usr/bin/R CMD /usr/local/lib/R/site-library/Rhipe/bin/RhipeMapReduce --slave --silent --vanilla" | tee -a /home/vagrant/rhRunner.sh
chmod 755 /home/vagrant/rhRunner.sh

## other R packages
R -e "install.packages('devtools', repos='http://cran.rstudio.com/')"
R -e "options(unzip = 'unzip', repos = 'http://cran.rstudio.com/'); library(devtools); install_github('tesseradata/datadr')"
R -e "options(unzip = 'unzip', repos = 'http://cran.rstudio.com/'); library(devtools); install_github('tesseradata/trelliscope')"
R -e "install.packages('testthat', repos='http://cran.rstudio.com/')"
R -e "install.packages('roxygen2', repos='http://cran.rstudio.com/')"



## install Spark
cd /home/vagrant/hadoop
wget http://mirrors.gigenet.com/apache/spark/spark-1.2.0/spark-1.2.0-bin-hadoop2.4.tgz
tar -xzf spark-1.2.0-bin-hadoop2.4.tgz

export SPARK_HOME=/home/vagrant/hadoop/spark-1.2.0-bin-hadoop2.4

## install SparkR
cd /home/vagrant/hadoop
git clone https://github.com/amplab-extras/SparkR-pkg
cd SparkR-pkg
SPARK_VERSION=1.2.0 SPARK_HADOOP_VERSION=2.4.0 ./install-dev.sh
rm -rf /usr/local/lib/R/site-library/SparkR
cp -R lib/SparkR /usr/local/lib/R/site-library/

echo export "SPARK_HOME=$SPARK_HOME" | sudo tee -a /etc/profile

## start Spark
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-slave.sh 1 spark://precise64:7077

## rstudio server
cd /tmp
wget -q https://s3.amazonaws.com/rstudio-server/current.ver -O currentVersion.txt
ver=$(cat currentVersion.txt)
wget http://download2.rstudio.org/rstudio-server-${ver}-amd64.deb
sudo dpkg -i rstudio-server-${ver}-amd64.deb
rm rstudio-server-*-amd64.deb currentVersion.txt
echo "www-port=80" | tee -a /etc/rstudio/rserver.conf
echo "rsession-ld-library-path=/usr/local/lib" | tee -a /etc/rstudio/rserver.conf
rstudio-server restart

## shiny server
ver=$(wget -qO- https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION)
wget https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-${ver}-amd64.deb -O shiny-server.deb
sudo dpkg -i shiny-server.deb
rm shiny-server.deb
sudo mkdir /srv/shiny-server/examples
sudo cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples
sudo chown -R shiny:shiny /srv/shiny-server/examples
echo "tessera ALL=(ALL) NOPASSWD: /bin/chown -R shiny /srv/shiny-server" | sudo tee -a /etc/sudoers


## hadoop test
# hadoop fs -mkdir input
# hadoop fs -put $HADOOP_HOME/etc/hadoop/*.xml input
# hadoop fs -ls input
# hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.0.jar grep input output 'dfs[a-z.]+'
# hadoop fs -cat output/part-r-00000

## Rhipe test
# library(testthat)
# test_package("Rhipe", "simple")

## Spark test
# R
# library(SparkR)
# sc <- sparkR.init(master="spark://precise64:7077", sparkEnvir=list(spark.executor.memory="1g"))
# rdd <- parallelize(sc, 1:10, 2)
# length(rdd)
# write.csv(iris, "/tmp/iris.csv")
# system("hadoop fs -copyFromLocal /tmp/iris.csv iris.csv")
# tt <- textFile(sc, "hdfs://localhost:8020/user/vagrant/iris.csv")
# collect(tt)






