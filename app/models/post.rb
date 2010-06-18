class Post < ActiveRecord::Base
  acts_as_rateable
  acts_as_taggable
  has_many :comments, :dependent => :destroy
  has_many :photos, :dependent => :destroy
  #has_and_belongs_to_many :groups
 has_and_belongs_to_many :groups
  has_one :users
  has_many :profiles, :through => :users 
  
  validates_presence_of :title, :message => "Sorry. You need to give your collection a title." 
  
  #acts_as_ferret
  # simplest case: just index all fields of this model:
  #acts_as_ferret

   # we use :store_class_name => true so that we can use 
   # the multi_search method to run queries across multiple
   # models
   acts_as_taggable
 #acts_as_ferret :store_class_name => true, :fields => { 
  #   :title      => { :boost => 2 }, 
   #  :post    => {},
    # :tag_string => {}
 #}

 def tag_string
   tags.collect { |t| t.name }.join(' ')
 end






   # only index the named fields:
   #acts_as_ferret :fields => ['author', 'content' ]

   # you can override the default to_doc method 
   # to customize what gets into your index. 
  # def to_doc
     # doc now has all the fields of our model instance, we 
     # just add another field to it:
   # doc = super
     # add a field containing the current time
    # doc <<  Ferret::Document::Field.new(
       #        'added', Time.now.to_i.to_s, 
       #        Ferret::Document::Field::Store::YES, 
       #        Ferret::Document::Field::Index::UNTOKENIZED)
     #return doc
  # end
   
 # acts_as_ferret :fields => { 'title' => { :boost => 2 }, 'post' => { :boost => 1 } }, :store_class_name => true
  
end
