require 'spec_helper'

describe 'mysql::client' do
  context 'redhat' do
    let (:facts) {{:osfamily => 'RedHat'}}
    it {should contain_package('mysql')}
    context 'php' do
      let(:params) {{:drivers => ['php','python','perl','ruby','python27']}}
      it {should contain_package('php-mysql')}
      it {should contain_package('ruby-mysql')}
      it {should contain_package('MySQL-python')}
      it {should contain_package('MySQL-python27')}
      it {should contain_package('perl-DBD-MySQL')}
    end
  end
end
