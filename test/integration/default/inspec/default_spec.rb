
describe service('rabbitmq-server') do
  it { should be_running }
  it { should be_enabled }
end

describe port('5672') do
  it { should be_listening }
end

describe file('/etc/rabbitmq/rabbitmq-env.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should eq "\n" }
end

describe file('/etc/rabbitmq/rabbitmq.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('mode') { should cmp '0644' }
  its('content') { should eq "\n" }
end
