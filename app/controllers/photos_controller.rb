class PhotosController < ApplicationController
  #before_filter :login_required, :only => :create 
   before_filter :check_login
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create ],
         :redirect_to => { :action => :collection, :id=> @post }

def list
           @photos = Photo.find_all
           @user=@posts.user_id
           @owner= User.find(@posts.user_id).name
end  

def popular_choice
  @id = Post.find_by_title(params[:title])
  redirect_to :action => 'collection', :id=> @id 
   
end
  
  def paginate_collection(coll, options = {}) 
    # Grab params and fix em up 
    per = options[:per_page].to_i 
    page = (params[:page] || 1).to_i 
    offset = (page - 1) * per 

    # Create a Paginator based on the collection data 
    pages = Paginator.new self, coll.size, per, page 

    # Grab the sub-set of the collection 
    paged = coll[offset..(offset + per - 1)] 

    return [pages, paged] 
  end
  
  def similar
    @randomtag = @posts.tags.find(:first, :order => 'RAND()')
    if @randomtag
    @suggestion = Tag.find(:first, :conditions => "name ='#{@randomtag}'", :order => 'RAND()').tagged
    end
  end
     
  
def collection
@photos = Photo.find_all
@post_id = params[:id]
@posts = Post.find(params[:id])
if !params[:poster]
@posts.visit_count+=1
end
@posts.save
@all_posts = Post.find_all
@popular=Post.find(:all, :order => 'visit_count DESC', :limit=>10)
if params[:poster]
@poster=@posts.photos.find(params[:poster]) 
else
@poster = @posts.photos.find(:first, :conditions => "poster_image= '1'", :order => 'RAND()')
end
similar

@user=@posts.user_id
@owner= User.find(@posts.user_id)
@profile = Profile.find_by_user_id(@owner.id)
 @total = @posts.comments.count
 @comments=@posts.comments
 
@groups = Group.find (:all, :conditions => "grouped_to ='#{@post_id}'")
 
 @per_page = 5 
 @comment_pages, @comments = paginate_collection @comments, :per_page => @per_page
  @tags = Tag.tags(:limit => 100, :order => "name desc").sort_by{ rand }
#@comment_pages, @comments = paginate :comments, :per_page => 10, :order => 'DESC'
@fave=Favourites.find_by_user_id_and_post_id(session[:user_id], @posts.id )

@is_friend=Friendship.find_by_friend_stage_and_friend_id("friend", @user, :conditions => ["user_id='#{@user_id}'"]) 
@is_friend2=Friendship.find_by_friend_stage_and_user_id("friend", @user, :conditions => ["friend_id='#{@user_id}'"]) 
if @is_friend or @is_friend2
@my_mate= true
end
@is_friend_pending=Friendship.find_by_friend_stage_and_friend_id("invite", @user, :conditions => ["user_id='#{@user_id}'"]) 
@is_friend_pending2=Friendship.find_by_friend_stage_and_user_id("invite", @user, :conditions => ["friend_id='#{@user_id}'"]) 
if @is_friend_pending
@pending= true
end
if @is_friend_pending2
@pending2= true
end

end

def comment 
@post = Post.find(params[:id])
@comment = Comment.new(params[:comment])
@comment.post_id = params[:id]
@comment.user_id = params[:user_id]
@comment.created_at = Time.now
@comment.update_attributes(params[:comment])
#@comment.save!
render :update do |page| 
  page.replace_html 'commentcount', "<h1>" + @post.comments.length.to_s + " Comments:</h1>" 
page.insert_html :top, 'commentholder', :partial => "comment_post", :locals => {:post => @post, :comment_post => @comment}
#page[comment].reset 
#page.form.reset('comment_form') 
end
#return if request.xhr?
end


  def show
@photo = Photo.find(params[:id])
@user_id = session[:user_id]
 @user_name = session[:user_name]
@post_id=@photo.post_id
@collection= Post.find(params[:collection])
  end

  def new
  @post = Post.find(params[:id])

  @photo = Photo.new
 @post.id = params[:id]
 @edit=true
  end

  def create
@post = Post.find(params[:id])
@photo = Photo.new(params[:photo])
@user_path="photo"+ @user_name
@photo.post_id = @post.id
@post.created_at = Time.now
@post.modified_at = Time.now
@post.update_attributes(params[:post])
  if @photo.save
      flash[:notice] = ' Photo was successfully uploaded. Upload another or view collection'
      @photos = Photo.find_all
      @post_id = params[:id]
      @posts = Post.find(params[:id])
      redirect_to :action => 'new', :id=> @post
  else
    render :action => 'new'
    end
  end

def edit
 
@photo = Photo.find(params[:id])
@post = Post.find(@photo.post_id)
@post_id=@photo.post_id
photo=@post.photos
@collection= Post.find(@post_id)
 
  end

   
   def tag
     @posts = Post.find(params[:id])
      @posts.modified_at = Time.now
      #@post.tag_with('red library book')
     @posts.tag_with(params[:tag_list])
     #@post.add_rating Rating.new(:rating => 2)
  @posts.update_attributes(params[:post])
  render :partial => "plugins/tags",  :locals => {:post => @posts}
  #render :action => 'tag_list' 
   end

  def update
     @photo = Photo.find(params[:id])
    @commit=params[:commit]
     if @commit=="Cancel"
       redirect_to :action => 'collection', :id => @photo.post_id
     else
   
    @posts = Post.find(@photo.post_id)
    @posts.modified_at = Time.now
    if @photo.update_attributes(params[:photo]) and @photo.save
      flash[:notice] = 'Photo was successfully updated.'
      redirect_to :action => 'collection', :id => @photo.post_id
    else
      render :action => 'edit'
    end
    end
  end
  def delete_photo
     @photo = Photo.find(params[:id])
       @post_id= @photo.post_id
      Photo.find(params[:id]).destroy
redirect_to :action => 'edit', :controller=>'posts', :id => @post_id
  end
  
  def destroy
   @photo = Photo.find(params[:id])
     @post_id= @photo.post_id
    Photo.find(params[:id]).destroy
   # redirect_to :action => 'collection', :id => @post_id
      #session[:referer] = request.referer 
      #  @referer=session[:referer]
        redirect_to :action => 'edit', :controller=>'posts', :id => @post_id
  end
end
