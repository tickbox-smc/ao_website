Puppet::Type.newtype :http, :is_capability => true do
  newparam :name, :is_namevar => true
  newparam :http_name
  newparam :http_port
  newparam :http_ip
end
