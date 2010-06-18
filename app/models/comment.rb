class Comment < ActiveRecord::Base
  belongs_to :post
  has_one :user
  ## VALIDATION 
   validates_presence_of :body, :message => "- You didn't type a message!" 
    validates_presence_of :user_id, :message => "Error. User not logged in!" 
     #validates_length_of :author, :within => 3..30, :message => "- Name is too long. Max of 30 characters" 
   #validates_length_of :email, :maximum => 100, :message => "- E-mail address is too long. Max of 100 characters" 
  # validates_length_of :url, :maximum => 100, :message => "- URL is too long. Max of 100 characters" 
   #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "- Not a valid e-mail address"
end
