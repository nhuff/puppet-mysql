Puppet::Type.newtype(:mysql_db) do
	@doc = "Manage a mysql database"
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
		desc "The name of the database"

		validate do |value|
			unless value =~ /^\w+$/
				raise ArgumentError, 
					"Database name must contain on [[:alanum:]_]"
			end
		end
	end

	newproperty(:char_set) do
		desc "The default characterset of database"
	end

	autorequire(:service) do
		['mysqld']
	end
end
