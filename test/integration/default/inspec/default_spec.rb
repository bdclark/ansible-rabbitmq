
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
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should include('NODE_PORT=5672') }
end

describe file('/etc/rabbitmq/rabbitmq.config') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should include('{port, 15672}') }
  its('content') { should include('{loopback_users, [<<"guest">>]}') }
  its('content') { should include('{default_user, <<"guest">>}') }
  its('content') { should include('{default_pass, <<"guest">>}') }
end

describe file('/etc/default/rabbitmq-server') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
end
