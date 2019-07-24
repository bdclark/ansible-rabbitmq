describe package('rabbitmq-server') do
  it { should be_installed }
  its('version') { should match('3.7.8') }
end

erlang_package = os.debian? ? 'erlang-base' : 'erlang'
describe package(erlang_package) do
  it { should be_installed }
  its('version') { should match('21.3.8') }
end

describe service('rabbitmq-server') do
  it { should be_running }
  it { should be_enabled }
end

describe port('5673') do
  it { should be_listening }
end

describe file('/etc/rabbitmq/rabbitmq-env.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should match(/^NODENAME="hare@.+"$/) }
end

describe file('/etc/rabbitmq/rabbitmq.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should match(/^listeners.tcp.default = 5673$/)}
end

describe file('/etc/rabbitmq/enabled_plugins') do
  it { should be_file }
  its('content') { should match(/\[.*?rabbitmq_management.*?\]\./) }
  its('content') { should match(/\[.*?rabbitmq_peer_discovery_consul.*?\]\./) }
  its('content') { should_not match('rabbitmq_peer_discovery_etcd') }
end

describe file('/var/lib/rabbitmq/.erlang.cookie') do
  it { should be_file }
  its('content') { should eql 'AnyStringWillDo' }
end
