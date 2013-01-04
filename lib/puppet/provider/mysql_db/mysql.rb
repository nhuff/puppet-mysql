Puppet::Type.type(:mysql_db).provide(:mysql) do
	desc "Provider for a mysql database"

	optional_commands :mysql      => 'mysql'

	def self.instances
		databases = []
		dbs = mysql('--defaults-file=/root/.my.cnf','-NB','mysql', '-e', 
			'select schema_name from information_schema.schemata')

		dbs.split("\n").each do |db|
			db.chomp!
			databases << new({:name => db})
		end
		databases

	end
	
	def create
		mysql('--defaults-file=/root/.my.cnf','mysql', '-e', 
			"create database #{@resource[:name]} character set #{@resource[:char_set]};")
	end

	def destroy
		mysql('--defaults-file=/root/.my.cnf','mysql','-e',"drop database #{@resource[:name]};")
	end

	def exists?
		mysql('--defaults-file=/root/.my.cnf','-NB','mysql','-e',
			"select schema_name from information_schema.schemata where schema_name='#{@resource[:name]}';"
			).match(/^#{@resource[:name]}$/)
	end

	def char_set
		mysql('--defaults-file=/root/.my.cnf','-NB','mysql','-e',
			"select DEFAULT_CHARACTER_SET_NAME from information_schema.schemata where schema_name='#{@resource[:name]}';").chomp()
	end

	def char_set=(should)
		mysql('--defaults-file=/root/.my.cnf','mysql','-e',
			"alter database #{@resource[:name]} character set #{should};")   
	end
end
