require 'digest/sha1'


class User < ActiveRecord::Base
  has_one :profile
  has_and_belongs_to_many :posts
  has_many :groups
  
  has_many :friendships,
     :foreign_key =>       'user_id',
     :class_name =>        'Friendship'
   has_many :befriendships,
     :foreign_key =>       'friend_id',
     :class_name =>        'Friendship'

     has_many :friends,
         :through =>     :friendships,
         :source =>  :befriendshipped

     has_many :befrienders,
         :through =>     :befriendships,
         :source =>  :friendshipped
  
  
  
  validates_presence_of     :name, 
                            :password, 
                            :email
                            
  validates_uniqueness_of   :name,
                            :message => "There is already user with same email"
 
  validates_length_of       :password, 
                            :minimum => 5,
                            :message => "should be at least 5 characters long"
# validates_format_of :email, :with => %r{\A(?:[_a-z0-9-]+)(\.[_a-z0-9-]+)*@([a-z0-9-]+)(\.[a-zA-Z0-9\-\.]+)*(\.[a- z]{2,4})\Z}i 
validates_format_of :email, :with =>  /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i                        
  attr_accessor :password_confirmation
  validates_confirmation_of :password
 #acts_as_fulltextable :fields, :to, :include, :in, :index 
 #acts_as_ferret :store_class_name => true
 # Ferret::Search::FuzzyQuery.default_min_similarity = 0.75
 # Ferret::Search::FuzzyQuery.default_prefix_length = 2
  def self.get_unsubscribe_code
  	 unsubscribe_code= unsubscribe_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  	end
  
  def self.authenticate(name, password)
    user = self.find_by_name(name)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end
  
  
  # 'password' is a virtual attribute
  
  def password
    @password
  end
  
  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end
  
  
  
  
  private
  
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt  # 'wibble' makes it harder to guess
    Digest::SHA1.hexdigest(string_to_hash)
  end
  


  
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  
  


end