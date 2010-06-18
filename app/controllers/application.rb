# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

include AuthenticatedSystem
  
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
  
    def check_mate(user)
      @is_friend=Friendship.find_by_friend_stage_and_friend_id("friend", user, :conditions => ["user_id='#{@user_id}'"]) 
      @is_friend2=Friendship.find_by_friend_stage_and_user_id("friend", user, :conditions => ["friend_id='#{@user_id}'"]) 
      if @is_friend or @is_friend2
      @my_mate= true
      end
      @is_friend_pending=Friendship.find_by_friend_stage_and_friend_id("invite", user, :conditions => ["user_id='#{@user_id}'"]) 
      @is_friend_pending2=Friendship.find_by_friend_stage_and_user_id("invite", user, :conditions => ["friend_id='#{@user_id}'"]) 
       
  end

  before_filter :check_login
  
  def check_login
     @user_name= session[:user_name]
     @user_id= session[:user_id]
    session[:referer] = request.referer 
  end

  def authorize
    if (!@user_name)
       
          flash[:notice] = 'You need to be logged in to access this feature.'
   redirect_to :controller=> 'login', :action => 'login'
   end
  end


end