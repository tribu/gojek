Problem Statement :

You have a complex infrastructure which requires multiple micro services to interact with each other. If given all the interactions are synchronous it will result in huge latencies and multiple point of failures.

You notice Kafka has proven to be a powerful component solving this problem in organizations like LinkedIn, Netflix and more.

Being a smart lazy ninja you like to automate everything.

So you need to build a one click/command solution which should setup a Kafka cluster for any required configuration.
You would like to use for setting up important environments like production with decent monitoring and logging placed in.
Also, to make it easier enough for any person from Product Teams to spin-up a development container of their own.
You are free to choose any configuration management tool and virtualisation technology.


SOLUTION:
1. I used the following to solve the problem
   a. VirtualBox running on my local laptop
   b. Vagrant to launch instance and create images
   c. Hosted Chef Enterprise to configure the server.(The free tier of hosted chef lets you configure upto 5 nodes for free)
   d. ChefSpec for testing

 2. Launch a skeleton Centos 7 server with hostname gojek-1

 3. Bootstrap the server as gojek-1. Run the zookeeper and kafka cookbooks.
    Test if kafka works in standalone mode.
    a) Run the following command to produce a new message
       echo "message from gojek-1" | kafka-console-producer.sh --broker-list localhost:9092 --topic topic-test > /dev/null
    b) Run the follwoing command to consume the above message
       kafka-console-consumer.sh --zookeeper localhost:2181 --topic topic-test  --from-beginning
     
     The output of step 3b) is "message from gojek-1"

 4. Next I created a base kafka image from this server using command
     vagrant package --output kafka-centos7.box --base gojek-1

 5. Using the base image from Step-4 I am now able to launch multiple servers to join. 
     In total I launched 2 more servers using the base image.

     vagrant init <  kafka-centos7.box
     vagrant up

 6. Bootsrap the new servers as gojek-1, gojek-2 and gojek-3

 7. Run chef cookbooks zookeeper and kafka. This willlaunch the zookeeper as a cluster as well kafka.

 8. Test if kafka is working as a cluster by producing message on one node and consuming it in another.

 Note: The following attributes are required to be set as part of bootstrap of each node.

     zookeeper - "This needs tod be set to true if teh node is configured for zookeeper"
     zkid      - "This needs to be unique number starting with 1"
     kafkaid   - "This needs to be unique number starting with 1"

In production :
- I would prefer to use AWS cloud. 
- Automate step 1 to 5 using PACKER. 
- Have jenkins launch new packer ami's for code change(upgrade of kafka and so on)
- And Terraform to launch instance in VPC, bootstrap the node and run chef-client.




