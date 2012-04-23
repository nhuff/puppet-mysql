require 'spec_helper'

describe 'mysql::client' do
  context 'redhat' do
    let (:facts) {{:osfamily => 'RedHat'}}
    it {should contain_package('mysql')}
  end
end
