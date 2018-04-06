
describe service('rabbitmq-server') do
  it { should be_running }
  it { should be_enabled }
end

describe port('5673') do
  it { should be_listening }
end

describe port('5671') do
  it { should be_listening }
end

describe port('15671') do
  it { should be_listening }
end

describe file('/etc/rabbitmq/rabbitmq-env.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should include('NODE_PORT=5673') }
end

describe file('/etc/rabbitmq/rabbitmq.config') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }

  its('content') do
    should include <<EOS
[
  {rabbitmq_management, [
    {listener, [
      {port, 15671},
      {ssl, true},
      {ssl_opts, [
        {cacertfile, "/etc/rabbitmq/ssl/cacert.pem"},
        {certfile, "/etc/rabbitmq/ssl/cert.pem"},
        {keyfile, "/etc/rabbitmq/ssl/key.pem"}
      ]}
    ]}
  ]},
  {rabbit, [
    {ssl_listeners, [5671]},
    {ssl_options, [
      {cacertfile, "/etc/rabbitmq/ssl/cacert.pem"},
      {certfile, "/etc/rabbitmq/ssl/cert.pem"},
      {keyfile, "/etc/rabbitmq/ssl/key.pem"},
      {verify, verify_peer},
      {fail_if_no_peer_cert, false}
    ]},
    {cluster_partition_handling,ignore},
    {disk_free_limit, "50MB"},
    {vm_memory_high_watermark, 0.5},
    {loopback_users, [<<"admin">>]},
    {default_user, <<"admin">>},
    {default_pass, <<"admin">>}
  ]}
].
EOS
  end
end

describe file('/etc/default/rabbitmq-server') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should include('ulimit -n 50000') }
end

describe file('/etc/rabbitmq/ssl') do
  it { should be_directory }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0750' }
  it { should be_grouped_into 'rabbitmq' }
end

%w[cacert cert key].each do |fname|
  describe file("/etc/rabbitmq/ssl/#{fname}.pem") do
    it { should be_file }
    its('owner') { should eq 'root' }
    its('mode') { should cmp '0640' }
    it { should be_grouped_into 'rabbitmq' }
  end
end

describe command('rabbitmqctl eval "node()."') do
  its('exit_status') { should eql 0 }
  its('stdout') { should include('hare@') }
end

describe command('rabbitmqctl cluster_status') do
  its('exit_status') { should eql 0 }
  its('stdout') { should include('{cluster_name,<<"rabbits">>}') }
end

describe command('rabbitmqctl list_vhosts') do
  its('exit_status') { should eql 0 }
  its('stdout') { should include('vhost1') }
end

describe command('rabbitmqctl list_permissions') do
  its('exit_status') { should eql 0 }
  its('stdout') { should match(/^admin1\s\.\*\s\.\*\s\.\*/) }
end

describe command('rabbitmqctl list_permissions -p vhost1') do
  its('exit_status') { should eql 0 }
  its('stdout') { should match(/^user1\s\.\*\s\.\*\s\.\*/) }
end
