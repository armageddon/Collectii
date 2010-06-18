class Photo < ActiveRecord::Base

belongs_to :posts

post_id=Post.id


file_column :pic, 
   :store_dir => @user_path,
    :base_url => @user_path,
   :magick => { 
         :versions => {
           :thumb => {:crop => "1:1",
           :geometry =>  '200x150!'},
            :medium => {:crop => "4:3",
            :geometry =>  '640!x480!'},
           # :crop is a ratio 
           # and cropping is done before resizing 
                                }
     }
   
  
 
       
       
## VALIDATION 
  validates_presence_of :pic, :message => "- You didn't upload!"
  validates_format_of :pic,  :with => %r{\.(gif|jpg|jpeg|png)$}i, :flash => "xxMust be a URL for a GIF, JPG, or PNG image" 
  
#acts_as_ferret :store_class_name => true
 # acts_as_ferret :fields => { 'caption' => { :boost => 2 }, 'pic' => { :boost => 1 } }, :store_class_name => true
  
  
end
  
  