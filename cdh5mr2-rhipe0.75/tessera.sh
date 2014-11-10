
function eVal {
    echo $1 | tee -a /home/vagrant/.Renviron
    # echo $1 | tee -a /etc/R/Renviron
    echo export $1 | tee -a /home/vagrant/.bashrc
    # echo export $1 | sudo tee -a /etc/profile
}

eVal 'HADOOP=/usr/lib/hadoop'
eVal 'HADOOP_HOME=/usr/lib/hadoop'
eVal 'HADOOP_CONF_DIR=/etc/hadoop/conf'
eVal 'HADOOP_BIN=$HADOOP_HOME/bin'
eVal 'HADOOP_OPTS=-Djava.awt.headless=true'
eVal 'HADOOP_LIBS=/etc/hadoop/conf:/usr/lib/hadoop/lib/:/usr/lib/hadoop/.//:/usr/lib/hadoop-hdfs/./:/usr/lib/hadoop-hdfs/lib/:/usr/lib/hadoop-hdfs/.//:/usr/lib/hadoop-yarn/lib/:/usr/lib/hadoop-yarn/.//:/usr/lib/hadoop-mapreduce/lib/:/usr/lib/hadoop-mapreduce/.//'
eVal 'LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH'
eVal 'RHIPE_RUNNER=/home/vagrant/rhRunner.sh'

sudo chown -R vagrant:vagrant .

echo '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server/' | sudo tee -a  /etc/ld.so.conf.d/jre.conf
echo '/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/' | sudo tee -a  /etc/ld.so.conf.d/jre.conf
echo '/usr/lib/hadoop/lib' | sudo tee -a  /etc/ld.so.conf.d/hadoop.conf

## build/install R

sudo apt-get -y update
sudo apt-get -y install pkg-config unzip libcairo2-dev libcurl4-openssl-dev screen libssl0.9.8 gdebi-core firefox

echo "deb http://cran.rstudio.com/bin/linux/ubuntu precise/" | sudo tee -a /etc/apt/sources.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9

sudo -E apt-get --yes --force-yes update

#### install R
sudo -E apt-get --yes --force-yes install r-base-dev
sudo chmod -R aou=rwx  /usr/local/lib/R/site-library

sudo R CMD javareconf
sudo su - -c "R -e \"install.packages('rJava', repos='http://www.rforge.net/')\""

## shiny package
sudo -E R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"

## rstudio
# sudo apt-get -y install libssl0.9.8
wget http://download2.rstudio.org/rstudio-server-0.98.994-amd64.deb
sudo dpkg -i rstudio-server-0.98.994-amd64.deb
# sudo apt-get -f --force-yes --yes install
# put rstudio on part 80
echo "www-port=80" | sudo tee -a /etc/rstudio/rserver.conf
echo "rsession-ld-library-path=/usr/local/lib" | sudo tee -a /etc/rstudio/rserver.conf
sudo rstudio-server restart

## shiny server
# sudo apt-get install gdebi-core
wget http://download3.rstudio.org/ubuntu-12.04/x86_64/shiny-server-1.2.1.362-amd64.deb
# no auto-yes!
# sudo gdebi shiny-server-1.2.1.362-amd64.deb
sudo dpkg -i shiny-server-1.2.1.362-amd64.deb
# copy shiny examples
sudo mkdir /srv/shiny-server/examples
sudo cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/examples
sudo chown -R shiny:shiny /srv/shiny-server/examples

## allow vagrant user to sudo chown
echo "vagrant ALL=(ALL) NOPASSWD: /bin/chown -R shiny /srv/shiny-server" | sudo tee -a /etc/sudoers

## protobuf
export PROTO_BUF_VERSION=2.5.0
wget https://protobuf.googlecode.com/files/protobuf-$PROTO_BUF_VERSION.tar.bz2
tar jxvf protobuf-$PROTO_BUF_VERSION.tar.bz2
cd protobuf-$PROTO_BUF_VERSION
./configure && make -j4
sudo make install
cd ..

## RHIPE
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
export PKG_CONFIG_PATH=/usr/local/lib
sudo chmod 777 /usr/local/lib/R/site-library
wget http://ml.stat.purdue.edu/rhipebin/Rhipe_0.75.0_cdh5mr2.tar.gz
R CMD INSTALL Rhipe_0.75.0_cdh5mr2.tar.gz

## RHIPE runner
echo "export LD_LIBRARY_PATH=/usr/local/lib" | sudo tee -a /home/vagrant/rhRunner.sh
echo "exec /usr/bin/R CMD /usr/local/lib/R/site-library/Rhipe/bin/RhipeMapReduce --slave --silent --vanilla" | sudo tee -a /home/vagrant/rhRunner.sh

sudo chown -R vagrant:vagrant /home/vagrant
sudo chmod 755 /home/vagrant
sudo chmod 755 /home/vagrant/rhRunner.sh

## devtools
sudo -E R -e "install.packages('devtools', repos='http://cran.rstudio.com/')"
## datadr
sudo -E R -e "options(unzip = 'unzip', repos = 'http://cran.rstudio.com/'); library(devtools); install_github('tesseradata/datadr')"
## trelliscope
sudo -E R -e "options(unzip = 'unzip', repos = 'http://cran.rstudio.com/'); library(devtools); install_github('tesseradata/trelliscope')"
## testthat
sudo -E R -e "install.packages('testthat', repos='http://cran.rstudio.com/')"



