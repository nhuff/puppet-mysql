Puppet::Type.newtype(:mysql_user) do
	@doc = "Type for managing a mysql database user."
	ensurable do
		newvalue(:present) do 
			provider.create
		end

		newvalue(:absent) do
			provider.destroy
		end

		defaultto :present
	end
	newparam(:name) do
		desc 'The username of the user in user@host format'
		validate do |value|
			username,hostname = value.split('@')
			debug "Username #{value} split user=#{username},host=#{hostname}"
			unless username =~ /^\w*$/
				raise ArgumentError,
					"User name portion must contain only [[:alanum:]_] #{value}"
			end

			unless hostname =~ /^[\w\-\.]+$/
				raise ArgumentError,
					"Hostname portion doesn't seem to be a valid hostname"
			end

			unless username.length < 17
				raise ArgumentError,
					"The username portion can be max 16 characters long"
			end
		end
	end

	newproperty(:password) do
		desc "The password of the user"
	end

	newproperty(:password_hash) do
		desc "Password hash of the user"
	end

	autorequire(:service) do
		['mysqld']
	end

end
