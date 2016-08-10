require 'chefspec'

describe 'kafka::install' do
  let(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['kafka']['version'] = '0.8.2.2'
      node.set['kafka']['download_url'] = 'http://mirror.cc.columbia.edu/pub/software/apache/kafka'
    end.converge(described_recipe)
  end

  before do
    stub_search(:node, "zk:true").and_return([])
  end

  let :path do
      '/usr/local/kafka/kafka_2.11-0.8.2.2/config/server.properties'
  end
  
  it 'creates remote file kafka_2.11-0.8.2.2.tgz' do
    expect(chef_run).to create_remote_file('/tmp/kafka_2.11-0.8.2.2.tgz')
  end

  it 'creates the configuration file' do
    expect(chef_run).to create_template(path).with({
    })
  end
end
