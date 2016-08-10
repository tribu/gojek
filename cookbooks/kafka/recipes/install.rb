
remote_file "/tmp/kafka_2.11-#{node[:kafka][:version]}.tgz" do
  source "#{node[:kafka][:download_url]}/#{node[:kafka][:version]}/kafka_2.11-#{node[:kafka][:version]}.tgz"
  notifies :run, "bash[untar_kafka]", :immediately
end

bash "untar_kafka" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    mkdir -p /usr/local/kafka
    tar -zxvf kafka_2.11-#{node[:kafka][:version]}.tgz --directory /usr/local/kafka
  EOH
  action :nothing
end

zookeeper_nodes_all = Array.new
zookeeper_nodes_all = search(:node, "zk:true")
zk_cluster = Array.new
zookeeper_nodes_all.each do |zookeeper_node|
	zk_cluster.push("#{zookeeper_node[:ipaddress]}:2181")
end

template "/usr/local/kafka/kafka_2.11-#{node[:kafka][:version]}/config/server.properties" do
  source "server.properties.erb"
  	variables({
  		:zk_cluster => zk_cluster
    })
  #notifies :run, "bash[kafka_restart]", :delayed
end

bash "kafka_restart" do
  user "root"
  cwd "/usr/local/kafka/kafka_2.11-#{node[:kafka][:version]}/bin"
  code <<-EOH
    kafka-server-stop.sh
    sleep 2
    nohup kafka-server-start.sh ../config/server.properties > /var/log/kafka/kafka.log 2>&1 &
  EOH
  action :nothing
end