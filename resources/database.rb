property :dbname, String, name_property: true
property :emconfiguration, String, default: 'LOCAL'
property :templatename, String, default: 'General_Purpose.dbc'
property :syspassword, String, default: node[:oracle][:rdbms][:sys_pw]
property :systempassword, String, default: node[:oracle][:rdbms][:system_pw]

load_current_value do
  #check if db exists
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
  end
end

action :destroy do
  #dbca -silent -deleteDatabase...
end
