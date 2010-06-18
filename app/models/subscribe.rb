class Subscribe < ActiveRecord::Base

file_column :image, :magick => { :versions => { "thumb" => "50x50", "medium" => "400x300>" }}
before_invite :make_activation_code
before_filter :make_activation_code


#def invites_left
#self.salt = self.object_id.to_s + rand.to_s 
#end

 #protected
    # If you're going to use activation, uncomment this too
  
end