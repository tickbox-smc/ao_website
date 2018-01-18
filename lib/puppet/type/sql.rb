Puppet::Type.newtype :sql, :is_capability => true do
  newparam :name, :namevar => true
  newparam :user 
  newparam :password 
  newparam :port 
  newparam :host 
  newparam :database 
end
