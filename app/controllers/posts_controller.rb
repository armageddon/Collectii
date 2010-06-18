class PostsController < ApplicationController
 before_filter :check_login
 # before_filter :authorize, :only =>  [ :create, :edit, :new, :destroy, :group_me]
#before_filter :login_required, :except=>['index', 'home']

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }
         

         def checklogin

            if !session[:user_id]
              flash[:notice] = 'Restricted area'[] 
              redirect_to(:action => 'login', :controller=> 'account')  
         end
         end

         def add_group
@posts= Post.find(:all, :conditions => "user_id ='#{@user_id}'", :order => 'created_at')
@groups = Group.find (:all,  :conditions => "grouped_to = 'params[:id]'")
@collection=params[:collection]
# needs to be unique
# meaning post has many groups


         #@posts.groups= Group.find(params[:group]) if params[:group]
         #@posts.groups.update_attributes(params[:group]) 
         # go through all users posts
          #params[:group].each do |group| 
          @posts.each do |post|
            @params[:group].each do |group| 

            if post.groups.include? group
           #if params[:group].include? group
              post.groups.update_attributes(params[:group]) 
            end
             end
         # process if they are grouped
         # save attributes

           end
         #redirect_to :action => 'group_me'

         end


  def addphoto
     @post = Post.find(params[:id])
     redirect_to :controller => 'photos', :action => 'new', :id=> @post
  end
  
  def add_to_favourites
    if session[:user_id]
    @post = Post.find(params[:id])
    if @fave=Favourites.find_by_user_id_and_post_id(session[:user_id], @post.id )
      flash[:notice] = 'You have already added this collection as a favourite'
    else 
         connector = Favourites.new 
           connector.user_id = session[:user_id]
           connector.post_id = @post.id 
           connector.save
            flash[:notice] = 'Collection added as favourite.' 
 end
    
    redirect_to :controller => 'photos', :action => 'collection', :id=> @post
     else
        flash[:notice] ="You need to be logged in"
        redirect_to :action => 'login', :controller=>'login', :id => params[:id]
      end
  end
  
  
  
def all_tags
  @tags = Tag.tags(:limit => 400, :order => "name desc")
  @post_pages, @posts = paginate :posts, :per_page => 10, :order => 'created_at DESC'
end
  
def all_cities
   @cities = Profile.find(:all, :order => 'city desc') 
end  
   
def collector
@collector = params[:id]
@user=User.find(@collector)
# this is stuff for user profile
@user_profile = User.find(@collector)
@profile = Profile.find_by_user_id(@user_profile.id)
if !@profile
@profile = Profile.new
end

if @user.id== @user_id
@owner= true
end 

# end user profile
@posts= Post.find(:all, :conditions => ["user_id=?", @user.id])
@per_page = 5 
 @posts_pages, @posts = paginate_collection @posts, :per_page => @per_page
@page_title = params[:id]
#check_mate(params[:id])
@fave=Favourites.find_all_by_user_id(@user)
@friends=Friendship.find_all_by_friend_stage_and_friend_id("friend", @user) 
@friends2=Friendship.find_all_by_friend_stage_and_user_id("friend", @user) 
@is_friend=Friendship.find_by_friend_stage_and_friend_id("friend", @user, :conditions => ["user_id='#{@user_id}'"]) 
@is_friend2=Friendship.find_by_friend_stage_and_user_id("friend", @user, :conditions => ["friend_id='#{@user_id}'"]) 
if @is_friend or @is_friend2
@my_mate= true
end
#pending so don't invite 
@is_friend_pending=Friendship.find_by_friend_stage_and_friend_id("invite", @user, :conditions => ["user_id='#{@user_id}'"]) 
@friends_pending=Friendship.find_all_by_friend_stage_and_user_id("invite", session[:user_id])
@friends_invite=Friendship.find_all_by_friend_stage_and_friend_id("invite",  @user)
@friends_invited=Friendship.find_by_friend_stage_and_friend_id("invite", session[:user_id], :conditions => ["user_id='#{@user}'"])

end

def destroy
      Post.find(params[:id]).destroy
      #redirect_to :action => 'list'
       session[:referer] = request.referer 
        @referer=session[:referer]
        redirect_to(session[:referer]) 
end
  
def group_me
if @user_profile = User.find(@user_id)
# find my posts
@posts= Post.find(:all, :conditions => "user_id ='#{@user_id}'", :order => 'created_at')
# find my groups
#@group=@posts.posts
#@groups = Group.find (:all, :conditions => "user_id ='#{@user_id}'")
@groups = Group.find (:all)
#@collection = params[:id]
@collection = Post.find(params[:id])
else
  login
end
end

def home
@tags = Tag.tags(:limit => 100, :order => "name desc")
@post_pages, @posts = paginate :posts, :per_page => 10, :order => 'created_at DESC'
 @pop=Post.find(:all, :order => 'visit_count DESC', :limit=>100)
 @popular=@pop.sort_by{ rand } 
 @comment=Comment.find(:all, :order => 'created_at DESC', :limit=>20)
 end
 
  
def index
@tags = Tag.tags(:limit => 100, :order => "name desc")
@post = Post.find(:first, :order => 'visit_count DESC')
@popular=Post.find(:all, :order => 'visit_count DESC', :limit=>10)
@posts=@post
#@visit_count=Post.find("visit_count", :order => 'visit_count DESC', :limit=>10)
#@post_pages, @posts = paginate :posts, :per_page => 10, :order => 'created_at DESC'
similar
end



def list
  items_per_page = 10
@tags = Tag.tags(:limit => 100, :order => "name desc")
@post_pages, @posts = paginate :posts, :per_page => 10, :order => 'created_at DESC'
end
         


def location
@city = params[:id]
@user_profile=Profile.find_by_city(@city)
#@user_id=@profile.user_id
#@user=User.find(@user_profile.user_id).id
#@posts= Post.find(:all, :conditions => ['city >=?', @city])
#@posts= @user_profile.posts
@posts= Post.find(:all, :conditions => ["user_id='#{@user_profile.user_id}'"], :limit => 200)
@page_title = params[:id]
  end
  
def new
if session[:user_name]
         @post = Post.new
else
      flash[:notice] = '&nbsp You are not logged in.'
     redirect_to :controller => 'login', :action => 'login' 
end
end
    
def new_collections

posts=Post.find(:all, :conditions => ['created_at > ?', 2.weeks.ago], :order => 'visit_count DESC', :limit=>200)
     #posts = Post.find(:all) 
     sorted_posts = posts.sort_by { |posts|  posts.rating }.reverse 
     #highest_rated_post = sorted_posts.first
     @ratings=sorted_posts
     # @ratings=Rating.find(:all, :order => 'rating DESC', :limit=>20)
        @page_title = "These boys are top rated"
        @per_page = 5 
@posts_pages, @posts = paginate_collection @ratings, :per_page => @per_page
end
        
def popular
  #sidebar :show_profile_side
  @posts=Post.find(:all, :order => 'visit_count DESC', :limit=>100)
  @per_page = 5 
  @posts_pages, @posts = paginate_collection @posts, :per_page => @per_page
  
    @page_title = "These boys are popular"
    @popular=@posts.sort_by{ rand } 
    @tags = Tag.tags(:limit => 100, :order => "name desc").sort_by{ rand }
    if @user_id
     @profile= Profile.find_by_user_id (@user_id)
     @user_profile=@profile
     owner= true
    end
end

def photo 
  @photo = Post.find(params[:id]).photos.create(params[:photo]) 
  
  if @photo.save 
    flash[:notice] = 'Your photo was added.' 
    redirect_to :action => 'show', :id => params[:id] 
  else 
    @post = Post.find(params[:id]) 
    render :action => 'show', :id => params[:id] 
  end 
end


def search
  @query = params[:search] || ''
  unless @query.blank?
   # @results = Post.find_by_contents @query 
    @results = Post.find_by_contents(@query)
   @results2 = Post.find_tagged_with(@query)
   @results3 = Photo.find_by_contents(@query)
   @results4 = User.find_by_contents(@query) 
  end
end

def user_by_location
    @users= Profile.find(:all,  :conditions => ["city='#{params[:id]}'"])
    @location = params[:id]
end

def rated
 posts=Post.find(:all, :order => 'visit_count DESC', :limit=>200)
 #posts = Post.find(:all) 
 sorted_posts = posts.sort_by { |posts|  posts.rating }.reverse 
 #highest_rated_post = sorted_posts.first
 @ratings=sorted_posts
 # @ratings=Rating.find(:all, :order => 'rating DESC', :limit=>20)
    @page_title = "These boys are top rated"
   # render_partial 'popular'
   @per_page = 5 
   @ratings_pages, @ratings = paginate_collection @ratings, :per_page => @per_page 
end

def show
    @posts = Post.find(params[:id])
     post = Post.find(params[:id])
    @owner= User.find(@posts.user_id).name
    @tags = Tag.tags(:limit => 100, :order => "name desc") 
   # @related_posts = @posts.related 
end
  
def show_tags
@page_title = params[:id]
if tag_name = params[:id] 
#find_by_tag(params[:id] )
@posts=Post.find_tagged_with(tag_name)
@tags = Tag.tags(:limit => 200, :order => "name desc")
@per_page = 15 
@posts_pages, @posts = paginate_collection @posts, :per_page => @per_page
end
end

def similar
@randomtag = @posts.tags.find(:first, :order => 'RAND()')
if @randomtag
@suggestion = Tag.find(:first, :conditions => "name ='#{@randomtag}'", :order => 'RAND()').tagged
end
end
  
def taglist
   if tag_name = params[:id] 
  @posts=Tag.find_by_name(tag_name).tagged 
  @tags = Tag.tags(:limit => 100, :order => "name desc")
@user_id = session[:user_id]

   # so now work out how to paginate these tag listings
      #  @post_pages, @posts = paginate :posts, :per_page => 10, :order => 'created_at DESC'
        @page_title = params[:id]
  end
  end
  
  def tag
    @tags = Tag.find_by_name(params[:id]).tagged
  end

def create
    check_login
    @post = Post.new(params[:post])
    @post.user_id=@user_id
    @post.created_at = Time.now
    @post.modified_at = Time.now
    @post.tag_with(params[:tag_list])
       
     #post.add_rating Rating.new(:rating => 2)
if @post.save
      flash[:notice] = 'Your collection was successfully created. <br>Now you can upload some pics'
      redirect_to :controller => 'photos', :action => 'new', :id=> @post
else
      render :action => 'new'
end
end

def edit
    @post = Post.find(params[:id])
end

  def update
    @post = Post.find(params[:id])
     @post.modified_at = Time.now
     #@post.tag_with('red library book')
    @post.tag_with(params[:tag_list])
    #@post.add_rating Rating.new(:rating => 2)
    if @post.update_attributes(params[:post])
      flash[:notice] = 'Post was successfully updated.'
      redirect_to :action => 'collection', :controller=>'photos', :id => @post
      #redirect_to :action => 'edit', :controller=>'photos', :id=> @post
    else
      render :action => 'edit'
    end
  end


  
end
