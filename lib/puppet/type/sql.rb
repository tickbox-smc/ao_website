Puppet::Type.newtype(:sql, :is_capability => true) do
  newparam(:name, :is_namevar => true)
  newparam(:user)
  newparam(:password)
  newparam(:port)
  newparam(:host)
  newparam(:database)
end
