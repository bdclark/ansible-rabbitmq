require 'spec_helper'

describe service('rabbitmq-server') do
  it { should be_running }
  it { should be_enabled }
end

describe port('5672') do
  it { should be_listening }
end

describe port('15672') do
  it { should be_listening }
end

describe file('/etc/rabbitmq/rabbitmq-env.conf') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  it { should contain 'NODE_PORT=5672' }
end

describe file('/etc/rabbitmq/rabbitmq.config') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
  it { should contain('{port, 15672}').from(/{rabbitmq_management, \[/).to(/}\]$/) }
  it { should contain '{loopback_users, [<<"guest">>]}' }
  it { should contain '{default_user, <<"guest">>}' }
  it { should contain '{default_pass, <<"guest">>}' }
end

describe file('/etc/default/rabbitmq-server') do
  it { should be_file }
  it { should be_owned_by 'root' }
  it { should be_mode 644 }
end
