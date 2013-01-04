require 'set'

Puppet::Type.newtype(:mysql_grant) do
	@doc = "Manage mysql grants"

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
		desc "The name of the grant"

		validate do |value|
			unless value =~ /.*@.+\/.+/
				raise ArgumentError,
					"name must be of form user@host/database"
			end
		end

	end

	newproperty(:privileges,:array_matching => :all) do
		desc "Array of database priveleges"

		all_privileges = [:update,:select, :delete, :insert]
		def insync?(is)
			is_set = Set.new(is)
			should_set = Set.new(@should)
			is_set == should_set
		end
		
		def is_to_s(currentvalue)
			currentvalue.collect{|x| x.to_s}.join(",")
		end

		def should_to_s(newvalue)
			newvalue.collect{|x| x.to_s}.join(",")
		end

		munge do |v|
			v.gsub(' ','_')
			v.to_sym
		end
#		newvalues(provider.db_privileges)
	end
		
	autorequire :mysql_db do
		matches = self[:name].match(/.+@.+\/(.+)/)
		unless matches.nil?
			[matches[1]]
		end
	end

	autorequire :mysql_user do
		matches = self[:name].match(/(.+@.+)\/.+/)
		unless matches.nil?
			[matches[1]]
		end
	end
	
end
