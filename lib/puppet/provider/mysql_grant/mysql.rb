require 'set'

Puppet::Type.type(:mysql_grant).provide(:mysql) do
	desc "Provider for a mysql database grant"
	optional_commands :mysql => 'mysql'

	def self.instances
		debug "instances"
		grants = []
		u_h_dbs = mysql('--defaults-file=/root/.my.cnf','-NB','mysql','-e','select user,host,db from db')
		debug "u_h_dbs:#{u_h_dbs}"
		u_h_dbs.split("\n").each do |u_h_db|
			user,host,db = u_h_db.split("\t")
			debug "user:%s,host:%s,db:%s"%[user,host,db]
			privs = priv_to_set(user,host,db)
			debug "privs:#{privs}"
			grants << new({
				:name       => "#{user}@#{host}/#{db}",
				:ensure     => :present,
				:privileges => privs.to_a
			})
		end
		grants
	end

	def split_name(string)
		debug "name_string: #{string}"
		matches = /^(.*)@(.+)\/(.+)$/.match(string).captures.compact
		case matches.length
			when 2
				{:user => '',:host => matches[0],:db => matches[1]}
			when 3
				{:user => matches[0],:host => matches[1],:db => matches[2]}
		end
	end

	def create
		name = split_name(@resource[:name])
		debug "privs:#{@resource[:privileges]}"
		grants = @resource[:privileges].collect{|x| x.to_s}.join(',')
		mysql('--defaults-file=/root/.my.cnf','mysql','-e',"grant %s on %s.* to '%s'@'%s';"%
			[grants,name[:db],name[:user],name[:host]]
		)
	end

	def destroy
		name = split_name(@resource[:name])
		mysql('--defaults-file=/root/.my.cnf','mysql','-e',
			"delete from db where user='%s' and host='%s' and db='%s';" %
			[name[:user],name[:host],name[:db]]
		)
	end

	def exists?
		name = split_name(@resource[:name])
		count = mysql('--defaults-file=/root/.my.cnf','-NB','mysql','-e',
			"select count(1) from db where user='%s' and host='%s' and db='%s'"%
			[name[:user],name[:host],name[:db]]
		).chomp
		debug "count:#{count.to_i}"
		count.to_i > 0 
	end

	def privileges
		name = split_name(@resource[:name])
		self.class.priv_to_set(name[:user],name[:host],name[:db]).to_a
	end	
	
	def privileges=(should)
		name = split_name(@resource[:name])
		should_set = Set.new(should)
		has_set = self.class.priv_to_set(name[:user],name[:host],name[:db])
		grant_set = should_set - has_set
		debug "grant_set:#{grant_set.to_a.join(',')}"
		revoke_set = has_set - should_set
		debug "revoke_set:#{revoke_set.to_a.join(',')}"

		unless grant_set.empty?
			grants = grant_set.to_a.collect{|x| x.to_s}.join(',')
			debug "grants: #{grants}"
			mysql('--defaults-file=/root/.my.cnf','mysql','-e',"grant %s on %s.* to '%s'@'%s'"%
				[grants,name[:db],name[:user],name[:host]]
			)
		end

		unless revoke_set.empty?
			revokes = revoke_set.to_a.collect{|x| x.to_s}.join(',')
			debug "revokes: #{revokes}"
			mysql('--defaults-file=/root/.my.cnf','mysql','-e',"revoke %s on %s.* from '%s'@'%s'"%
				[revokes,name[:db],name[:user],name[:host]]
			)
		end
	end

	def self.priv_to_set(user,host,database)
		db_privileges = [ :select, :insert, :update, :delete,
			:create, :drop, :grant, :references, :index,
			:alter, :"create temporary tables", :"lock tables", :"create view",
			:"show view", :"create routine", :"alter routine", :execute
		]

		privs_def = db_privileges.collect do |x| 
			string = x.to_s
			if string == "create temporary tables"
				string = "create_tmp_table"
			end
			string.gsub!(' ','_')
			string+'_priv'
		end.join(',')

		privs = mysql('--defaults-file=/root/.my.cnf','-NB','mysql','-e',
			"select %s from db where user='%s' and db='%s' and host='%s';"%
			[privs_def,user,database,host]).chomp.split("\t")

		if privs.empty?
			return Set.new([])
		end

		priv_hash = Hash[db_privileges.zip(privs)]
		priv_hash.delete_if{|key,value| value == "N"}
		debug "priv_hash:#{priv_hash.keys}"
		Set.new(priv_hash.keys)
	end	

	def flush
		mysql('--defaults-file=/root/.my.cnf','mysql','-e','flush privileges;')
	end
end
