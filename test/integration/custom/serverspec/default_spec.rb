require 'spec_helper'

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
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  it { should contain 'NODE_PORT=5673' }
  # it { should contain 'NODENAME=5673' }
end

describe file('/etc/rabbitmq/rabbitmq.config') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  it { should contain '{loopback_users, [<<"admin">>]}' }
  it { should contain '{default_user, <<"admin">>}' }
  it { should contain '{default_pass, <<"admin">>}' }
  it { should contain '{disk_free_limit, "50MB"}' }
  it { should contain '{vm_memory_high_watermark, 0.5}' }

  it { should contain('{port, 15671}').from(/{rabbitmq_management, \[/).to(/ssl_opts,/) }
  it { should contain('{ssl, true}').from(/{rabbitmq_management, \[/).to(/ssl_opts,/) }
  it { should contain('{cacertfile, "etc/rabbitmq/ssl/cacert.pem"}').from(/ssl_opts,/).to(/]}$/) }
  it { should contain('{certfile, "/etc/rabbitmq/ssl/cert.pem"}').from(/{ssl_opts,/).to(/]}$/) }
  it { should contain('{keyfile, "/etc/rabbitmq/ssl/key.pem"}').from(/{ssl_opts,/).to(/]}$/) }

  # ssl
  it { should contain '{ssl_listeners, [5671]}' }
  it { should contain('{cacertfile, "etc/rabbitmq/ssl/cacert.pem"}').from(/{ssl_options, \[/).to(/]},/) }
  it { should contain('{certfile, "/etc/rabbitmq/ssl/cert.pem"}').from(/{ssl_options, \[/).to(/]},/) }
  it { should contain('{keyfile, "/etc/rabbitmq/ssl/key.pem"}').from(/{ssl_options, \[/).to(/]},/) }
  it { should contain('{verify, verify_peer}').from(/{ssl_options, \[/).to(/]},/) }
  it { should contain('{fail_if_no_peer_cert, false}').from(/{ssl_options, \[/).to(/]},/) }
end

describe file('/etc/default/rabbitmq-server') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  it { should contain 'ulimit -n 50000' }
end

describe file('/etc/rabbitmq/ssl') do
  it { should be_directory }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'rabbitmq' }
  it { should be_mode '750' }
end

%w(cacert cert key).each do |fname|
  describe file("/etc/rabbitmq/ssl/#{fname}.pem") do
    it { should be_file }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'rabbitmq' }
    it { should be_mode '640' }
  end
end

describe command('rabbitmqctl eval "node()."') do
  its(:exit_status) { should eql 0 }
  its(:stdout) { should contain 'hare@' }
end

describe command('rabbitmqctl cluster_status') do
  its(:exit_status) { should eql 0 }
  its(:stdout) { should contain '{cluster_name,<<"rabbits">>}' }
end

describe command('rabbitmqctl list_vhosts') do
  its(:exit_status) { should eql 0}
  its(:stdout) { should contain 'vhost1' }
end

describe command('rabbitmqctl list_permissions') do
  its(:exit_status) { should eql 0 }
  its(:stdout) { should match /^admin1\s\.\*\s\.\*\s\.\*/ }
end

describe command('rabbitmqctl list_permissions -p vhost1') do
  its(:exit_status) { should eql 0 }
  its(:stdout) { should match /^user1\s\.\*\s\.\*\s\.\*/ }
end
