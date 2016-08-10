require 'chefspec'

describe 'zookeeper::install' do

  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['zookeeper']['version'] = 'zookeeper-3.4.6'
      node.set['zookeeper']['download_url'] = 'http://apache.claz.org/zookeeper'
      node.set['zookeeper']['datadir'] = '/var/zookeeper/data'
    end.converge(described_recipe)
  end

  before do
    stub_search(:node, "zk:true").and_return([])
  end

  let :path do
      '/usr/local/zookeeper/zookeeper-3.4.6/conf/zoo.cfg'
  end

  it 'creates remote file zookeeper-3.4.6.tar.gz' do
    expect(chef_run).to create_remote_file('/tmp/zookeeper-3.4.6.tar.gz')
  end

  it 'creates the configuration file' do
    expect(chef_run).to create_template(path).with({
    })
  end
end
