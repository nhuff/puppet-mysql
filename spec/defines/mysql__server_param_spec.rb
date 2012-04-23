require 'spec_helper'

describe 'mysql::server_param' do
  let(:title) {'test1'}
  let(:pre_condition) {'class {"mysql::server":}'}

  context 'redhat' do
    let(:facts) {{:osfamily => 'RedHat'}}
    context 'mysqld' do
      let(:params) {{:value => 'val1'}}
      it {should contain_augeas('mysql-test1').with(
          :incl    => '/etc/my.cnf',
          :lens    => 'mysql.lns',
          :context => "/files/etc/my.cnf/target[. = 'mysqld']",
          :changes => "set test1 val1"
        )
      }
    end
    context 'mysqld_safe' do
      let(:params) {{:value => 'val1',:section => 'mysqld_safe'}}
      it {should contain_augeas('mysql-test1').with(
          :incl    => '/etc/my.cnf',
          :lens    => 'mysql.lns',
          :context => "/files/etc/my.cnf/target[. = 'mysqld_safe']",
          :changes => "set test1 val1"
        )
      }
    end
  end
end
