class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name,:email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body
 validates :first_name, :presence=>true
 validates :last_name , :presence => true
 after_create :add_to_mailchimp
 
  def add_to_mailchimp
   opts = {double_optin: false,  send_welcome: true, apikey: "dd9b87576b8e5a7436e69f54d2d8e4ce-us4"}
   member_email = self.email
   g = Gibbon.new(opts[:apikey])
	 member_info = g.listMemberInfo({:id => "2e58b31ab5", :email_address => member_email})
   if member_info["success"] == 0
     g.listSubscribe({:id => "2e58b31ab5", :email_address => member_email,:first_name=>self.first_name,:last_name=>self.last_name,:update_existing => true}.merge opts)
   elsif member_info["success"] == 1
     if member_info['data'].first['status'] == 'subscribed'
       merge_vars = g.listMergeVars({:id => "2e58b31ab5"}.merge(opts))
       g.listUpdateMember({:id => "2e58b31ab5", :email_address => member_email,:merge_vars => merge_vars}.merge(opts))
     end
     true
   end
  end
    def name      
      "#{self.first_name} #{self.last_name}"
  end
end
