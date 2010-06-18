class UserController < ApplicationController
 before_filter :check_login, :except => [:activate]

 def activate
 flash.clear
 if params[:activation_code] and @user = User.find_by_activation_code(params[:activation_code]) 
 @user.confirmed=1
 #@user.invitee=0
 if @user
 @user.confirm_date=Time.now()
 current_user = @user
 session[:username] = @user.login
 session[:user_id]=@user.id
 flash[:notice] = "Your account has been activated." 

@user_email= @user.login + "<" + @user.email + ">"
 Notifier.queue=false
   Notifier::deliver_activation_thanks(@user_email,@user)
   else
   flash[:error] = "Sorry. Unable to activate the account.  Did you provide the correct information?" 
   end

  # if @user.organisation=="Admin" or @user.organisation=="Contributor"
  #   flash[:notice] = "Welcome. Your account has been activated. Glad to have you on board. " 
   #redirect_to(:action => 'login', :controller=>'account',:id=>@user.id) 
   #else
   redirect_to(:action => 'collector', :controller=>'posts', :id=>@user.id)
   #end

   else
   flash.clear
  flash[:error] = "Sorry. Unable to activate the account.  Did you provide the correct information?" 

   end
 rescue ActiveRecord::RecordInvalid
    flash[:notice] = @errors+ "ERROR: That login already exists." 
      render :action => 'sign_up', :controller=>'subscribe', :id=>@user.id, :user=>@user
 	rescue Net::SMTPFatalError
 	flash[:notice] = "ERROR:　There was a problem with sending to that mail address - plese try again" 
 	render :action => 'activate', :controller=>'subscribe', :id=>@user.id, :user=>@user
 	rescue Net::SMTPSyntaxError

   end


  def edit_profile
    @user = User.find(@user_id)
  if @profile = Profile.find_by_user_id(@user_id)
 @posts= Post.find(:all, :conditions => user_id =session[:user_id])
else
@profile = Profile.new
@profile.user_id= @user_id
@profile.save
      end
  end

  def update
@user_profile = Profile.find_by_user_id(params[:id])
@user_profile.user_id=@user_id

if @user_profile.update_attributes(params[:profile]) 
   flash[:notice] = '<br>Profile was successfully updated.'
   redirect_to :action => 'collector', :controller=>'posts', :id=>params[:id]
   # else
   #   render :action => 'edit'
 end
  end

  def similar
    @randomtag = @posts.tags.find(:first, :order => 'RAND()')
    if @randomtag
    @suggestion = Tag.find(:first, :conditions => "name ='#{@randomtag}'", :order => 'RAND()').tagged
    end
  end

  def view_profile
#@user_id= session[:user_id]
#@user_id= (params[:id])
if params[:id] != @user_id.to_s
  @user_profile = User.find(params[:id])
  @owner = false
else
   @user_profile = User.find(@user_id)
  # check to see if user is logged in
 @owner = true
end
@friends=Friendship.find_all_by_friend_stage_and_friend_id("friend", session[:user_id])
@friends2=Friendship.find_all_by_friend_stage_and_user_id("friend", session[:user_id]) 
@friends_pending=Friendship.find_all_by_friend_stage_and_user_id("invite", session[:user_id])
@friends_invite=Friendship.find_all_by_friend_stage_and_friend_id("invite", params[:id])


@profile = Profile.find_by_user_id(@user_id)
if !@profile
  @profile = Profile.new
   end
   # list all user's collections
   # there's something strange going on here
   # it won't call user_id, but used to
 @posts= Post.find(:all, :conditions => "user_id ='#{@user_id}'", :order => 'RAND()')
 #@posts= Post.find_by_user_id(@user_id)
# select from posts where user_id = xx join select * from comments 
end

def unsubscribe
if @user = User.find_by_unsubscribe_code(params[:id])
	@unsubscriber = Unsubscriber.new()	
	@unsubscriber.login=@user.login
	@unsubscriber.display_name=@user.display_name
	@unsubscriber.name=@user.name
	@unsubscriber.email=@user.email
	@unsubscriber.signup_date=@user.signup_date
	@unsubscriber.last_login=@user.last_login
	@unsubscriber.unsubscribed_at=Time.now()
	@unsubscriber.save
	@user.destroy
	  cookies.delete :login
    #session.delete :user_id
    cookies[:login]=nil
  self.current_user.forget_me if logged_in?
  cookies.delete :auth_token
  cookies.delete :user_id
  cookies.delete :username
  cookies.delete :role

  session[:role]=nil
  session[:user_id]=nil
  session[:active]=nil
  reset_session
	flash[:notice] = 'Unsubscribed' 
	#	redirect_to :action=>'unsubscribe_notice'
		else
flash[:notice] = 'No such subscriber'
	#	redirect_to :action=>'unsubscrib'
		end
	
	end

end