class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  # for registration login
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :openid_authenticatable
  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :identity_url

  def self.build_from_identity_url(identity_url)
    User.new(:identity_url => identity_url, :password => 'OPENID_UNKNOWNPASSWD')
  end
  
  def self.openid_required_fields
    ["fullname", "email", "http://axschema.org/namePerson", "http://axschema.org/contact/email"]
  end
  
  def openid_fields=(fields)
  fields.each do |key, value|
    # Some AX providers can return multiple values per key
    if value.is_a? Array
      value = value.first
    end

    case key.to_s
    when "fullname", "http://axschema.org/namePerson"
      self.name = value
    when "email", "http://axschema.org/contact/email"
      self.email = value
    when "gender", "http://axschema.org/person/gender"
      self.gender = value
    else
      logger.error "Unknown OpenID field: #{key}"
    end
  end
end
end
