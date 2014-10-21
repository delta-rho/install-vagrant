#! /bin/sh

cd /home/ubuntu/

echo "Add Cloudera repositories"
wget -c http://archive.cloudera.com/cdh5/one-click-install/precise/amd64/cdh5-repository_1.0_all.deb
sudo dpkg -i cdh5-repository_1.0_all.deb
curl -s http://archive.cloudera.com/cdh5/ubuntu/precise/amd64/cdh/archive.key | sudo apt-key add -

sudo apt-get update

echo "Install Java"
sudo apt-get install --force-yes --yes openjdk-7-jdk

echo "Install Hadoop with YARN"
sudo apt-get install --yes hadoop-conf-pseudo

echo "Starting Hadoop and Verifying it is Working Properly"
dpkg -L hadoop-conf-pseudo

echo "Format the NameNode."
sudo -u hdfs hdfs namenode -format

echo "Start HDFS"
for x in `cd /etc/init.d ; ls hadoop-hdfs-*` ; do sudo service $x start ; done

# echo "Remove the old /tmp if it exists:"
# sudo -u hdfs hadoop fs -rm -r /tmp

echo "Create the new directories and set permissions:"
sudo -u hdfs hadoop fs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hadoop fs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
sudo -u hdfs hadoop fs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hadoop fs -chown yarn:mapred /var/log/hadoop-yarn

echo "Verify the HDFS File Structure:"
sudo -u hdfs hadoop fs -ls -R /

echo "Start YARN"
sudo service hadoop-yarn-resourcemanager start
sudo service hadoop-yarn-nodemanager start
sudo service hadoop-mapreduce-historyserver start

echo "Create User Directories"
sudo -u hdfs hadoop fs -mkdir /user
sudo -u hdfs hadoop fs -chown ubuntu /user
sudo -u hdfs hadoop fs -mkdir /user/ubuntu
sudo -u hdfs hadoop fs -chown ubuntu /user/ubuntu

echo "Install HiveServer2"
sudo apt-get install --yes hive-server2
