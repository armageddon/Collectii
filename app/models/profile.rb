class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :posts, :through => :users 
  #acts_as_ferret :store_class_name => true
  
  file_column :pic, :magick => { 
        :versions => { "thumb" => "50x50", "medium" => "500x400>" }
      }
end
