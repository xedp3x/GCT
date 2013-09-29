class Group < ActiveLdap::Base
  ldap_mapping dn_attribute: "cn",
               prefix: "ou=Groups",
               classes: ["posixGroup", "top"]

  has_many :members, :class_name => "Person", :wrap => "memberUid"
  has_many :admins, :class_name => "Person", :wrap => "adminUid"
  has_many :primary_members, :class_name => 'Person',
           :foreign_key => 'gidNumber',
           :primary_key => 'gidNumber'
  def admin? uid
    list = if self.adminUid.kind_of?(Array) then self.adminUid else [self.adminUid] end
    return list.include? uid
  end
end
