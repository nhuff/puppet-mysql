Puppet::Type.type(:mysql_user).provide(:mysql) do
	desc "Provider for a mysql user"

	optional_commands :mysql => 'mysql'

	mk_resource_methods

	def self.password_to_hash(password)
		debug "mysql_user password_to_hash"
		mysql('-NB','mysql','-e',"select password('#{password}');").chomp!
	end

	def self.instances
		debug "mysql_user instances"
		users = []
		us = mysql('-NB','mysql','-e','select user,host,password from user;')
		us.split("\n").each do |u|
			username,hostname,pass = u.split("\t")
			user_host = [username,hostname].join('@')
			debug "#{user_host}"
			users << new({:name => user_host, 
							:password_hash => pass, 
							:ensure => :present
						})
		end
		users
	end
	
	def self.prefetch(resources)
		instances.each do |prov|
			if resource = resources[prov.name]
				resource.provider = prov
			end
		end
	end

	def create
		debug "mysql_user create"
		@property_hash[:ensure] = :present
		mysql('mysql','-e',"create user '%s' identified by '%s';" %
				[@resource[:name].sub("@","'@'"),@resource[:password]])
	end

	def destroy
		debug "mysql_user destroy"
		mysql('mysql','-e',"drop user '%s'" % @resource[:name].sub("@", "'@'"))
		@property_hash[:ensure] = :absent
	end

	def exists?
		debug "mysql_user exists?"
		@property_hash[:ensure] == :present
	end

	def password
		hash = self.class.password_to_hash(@resource.should(:password))
		if @property_hash[:password_hash] == hash
			return @resource.should(:password)
		else
			:absent
		end
	end

	def password=(should)
		hash = self.class.password_to_hash(should)
		mysql('mysql','-e',"set password for '%s' = password('%s')"%
			[ @resource[:name].sub("@", "'@'"), should ])
		@property_hash[:password] = should
		@property_hash[:password_hash] = hash
	end

	def flush
		debug "in flush"
		mysql('mysql','-e','flush privileges;')
		@property_hash.clear
	end
	
end

