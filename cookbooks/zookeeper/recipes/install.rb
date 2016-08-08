
remote_file "/tmp/#{node[:zookeeper][:version]}.tar.gz" do
  source "#{node[:zookeeper][:download_url]}/#{node[:zookeeper][:version]}/#{node[:zookeeper][:version]}.tar.gz"
  notifies :run, "bash[untar_zookeeper]", :immediately
end

bash "untar_zookeeper" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    mkdir -p /usr/local/zookeeper
    tar -zxvf #{node[:zookeeper][:version]}.tar.gz --directory /usr/local/zookeeper
  EOH
  action :nothing
end

directory '#{node[:zookeeper][:datadir]}'

template "#{node[:zookeeper][:datadir]}/myid" do
  source "myid.erb"
  notifies :run, "bash[zookeeper_restart]", :delayed
end

# Find all ZooKeeper Nodes
zookeeper_nodes_all = Array.new
zookeeper_nodes_all = search(:node, "zk:true")

template "/usr/local/zookeeper/#{node[:zookeeper][:version]}/conf/zoo.cfg" do
  source "zoo.cfg.erb"
  	variables({
      :zookeeper_datdir => node[:zookeeper][:datadir],
      :zookeeper_nodes_all => zookeeper_nodes_all
    })
  notifies :run, "bash[zookeeper_restart]", :delayed
end

bash "zookeeper_restart" do
  user "root"
  cwd "/usr/local/zookeeper/#{node[:zookeeper][:version]}/bin"
  code <<-EOH
    zkServer.sh stop
    sleep 2
    zkServer.sh start
  EOH
  action :nothing
end

  