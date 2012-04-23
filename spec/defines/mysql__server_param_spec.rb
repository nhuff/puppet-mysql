require 'spec_helper'

describe 'mysql::server_param' do
  let(:title) {'test1'}
  let(:params) {{:value => 'val1'}}
  let(:pre_condition) {'class {"mysql::server":}'}

  context 'redhat' do
    let(:facts) {{:osfamily => 'RedHat'}}
    it {should contain_augeas('mysql-test1').with(
        :incl    => '/etc/my.cnf',
        :lens    => 'mysql.lns',
        :context => "/files/etc/my.cnf/target[. = 'mysqld']",
        :changes => "set test1 val1"
      )
    }
  end
end
