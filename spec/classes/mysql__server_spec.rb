require 'spec_helper'

describe 'mysql::server' do
  context 'redhat' do
    let (:facts) {{:osfamily => 'RedHat'}}
    it {should contain_package('mysql-server')}
    it {should contain_service('mysqld')}
    it {should contain_file('/etc/my.cnf')}
    it {should contain_file('/root/.my.cnf')}
  end
  context 'manage db' do
    let (:params) {{:manage_dbs => true}}
    it {should contain_resources('mysql_db').with_purge('true')}
  end
  context 'manage users' do
    let (:params) {{:manage_users => true}}
    it {should contain_resources('mysql_user').with_purge('true')}
    it {should contain_resources('mysql_grant').with_purge('true')}
  end
end
