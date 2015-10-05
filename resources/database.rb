property :dbname, String, name_property: true
property :emconfiguration, String, default: 'LOCAL'
property :templatename, String, default: 'General_Purpose.dbc'
property :syspassword, String, default: node[:oracle][:rdbms][:sys_pw]
property :systempassword, String, default: node[:oracle][:rdbms][:system_pw]
property :databases, Array, default: []

load_current_value do
  if ::File.exist?('/etc/oratab')
    oratab = ::File.open('/etc/oratab', 'r')
    oratab.each_line do |line|
      next if line.chomp! =~ /^#/
      databases << line.split(':').first
    end
  end
end

action :create do
  execute "dbca create #{dbname}" do
    command "dbca -silent -createDatabase \
      -emConfiguration #{emconfiguration} \
      -templateName #{templatename} \
      -gdbname #{dbname} \
      -sid #{dbname} \
      -sysPassword #{syspassword} \
      -systemPassword #{systempassword}"
    action :run
    user 'oracle'
    environment node[:oracle][:rdbms][:env]
    not_if do
      databases.include? dbname
    end
  end
end

action :delete do
  execute "dbca delete #{dbname}" do
    command "dbca -silent -deleteDatabase \
     -sourceDB #{dbname}"
    action :run
    user 'oracle'
    environment node[:oracle][:rdbms][:env]
    only_if do
      databases.include? dbname
    end
  end
end
