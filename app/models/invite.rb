require 'digest/sha1' 
class Invite < ActiveRecord::Base
   has_and_belongs_to_many :users
   validates_presence_of     :invite_name, :invite_email
   validates_length_of       :invite_name,    :within => 2..40
   validates_length_of       :invite_email,    :within => 3..100
   #validates_uniqueness_of   :invite_email, :case_sensitive => false
   validates_format_of :invite_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => 'email must be valid' # def invites_left
   
 	def longdate (eventdate)
 		dayname= eventdate.strftime("%A")[]
 		month= eventdate.strftime("%B")[]
 		day= eventdate.strftime("%d")
 		year = eventdate.strftime("%Y")
 		result = dayname + " " + day + " "  + month + " " + year
 		result
 	end
   
end
