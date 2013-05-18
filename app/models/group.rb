class Group < ActiveLdap::Base
  ldap_mapping dn_attribute: "cn",
               prefix: "ou=Groups",
               classes: ["posixGroup", "top"]

  has_many :members, :class_name => "Person", :wrap => "memberUid"
  has_many :primary_members, :class_name => 'Person',
           :foreign_key => 'gidNumber',
           :primary_key => 'gidNumber'
end
