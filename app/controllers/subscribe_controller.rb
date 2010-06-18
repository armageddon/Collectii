class SubscribeController < ApplicationController
include AuthenticatedSystem
observer :user_observer 
 
before_filter :checklogin, :except=>['welcome','unsubscribe_notice','unsubscribe','resend_activation_mail', 'add_language', 'check_lang', 'language','subscribe_me', 'index','sign_up','login', 'logout', 'activate','activate_invite','activate_invite_save', 'not_activated', 'get_hyp', 'your_preferences']
#before_filter :check_lang
before_filter :make_activation_code, :only=>['subscribe_me']
after_filter :delete_login_cookie, :only => [:logout]


# this is only for people who subscribe themselves - they go into subscriber table
def activate
flash.clear
if params[:activation_code] and @user = User.find_by_activation_code(params[:activation_code]) 
@user.confirmed=1
@user.invitee=0
if @user and @user.activate
@user.activated_at=Time.now()
current_user = @user
session[:username] = @user.login
session[:role]=@user.organisation
session[:user_id]=@user.id
flash[:notice] = "Your account has been activated." 

@events = Event.find_soon(session[:lang])
 
@timeframe = Event.get_timeframe
#@timeframe_j = @event_date.localize("%A %d %B") + " - " +  @eow.localize("%A %d %B")
  @user_email= @user.login + "<" + @user.email + ">"
Notifier.queue=false
  Notifier::deliver_activation_thanks(@user_email,@user,@events, @timeframe)
  else
  flash[:error] = "Sorry. Unable to activate the account.  Did you provide the correct information?" 
  end

  if @user.organisation=="Admin" or @user.organisation=="Contributor"
    flash[:notice] = "Welcome. Your account has been activated. Glad to have you on board. " 
  #redirect_to(:action => 'login', :controller=>'account',:id=>@user.id) 
  else
  redirect_to(:action => 'your_preferences', :controller=>'subscribe', :activation_code=> params[:activation_code])
  end

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
  


  def checklogin
      if !session[:user_id] and !cookies[:user_id]
        flash[:notice] = 'Please login to continue' [] 
        redirect_to(:action => 'login', :controller=>'front') 
      end
      end
      
  def index
    if session[:lang] and !params[:activation_code]
      redirect_to(:action => 'sign_up') 
    end
   end
  
   
def make_activation_code
@activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
end
   
    
    
def send_list
Mailings::deliver_weekly_list
end

def subscribe_me
  @errors=""
params[:user][:email]=params[:user][:login]
@users=User.find(:all)
@user = User.new(params[:user])
@user.last_login=Time.now()
@lang=session[:lang]
@user.language=session[:lang]
@user.fullname==params[:user][:login].strip
@user.email = params[:user][:email].strip
@user.login = params[:user][:login].strip
@user.organisation="Subscriber"
if User.find_by_email(params[:user][:login].strip) and User.find_by_email(params[:user][:login].strip).confirmed 
@user.errors.add(:login, "This email already exists."[])
result=true
elsif User.find_by_login(params[:user][:login].strip) and User.find_by_login(params[:user][:login].strip).confirmed 
	@user.errors.add(:login, "This email already exists."[])
	result=true
elsif params[:user][:password] != params[:user][:password_confirmation]
	@user.errors.add (:password, "Password no match"[])
	result=true
	
end
if result==true
render :action => 'sign_up'
return
end

  @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
@user_mail= @user.email + "<" + @user.email + ">"
Notifier.queue=false
Notifier::deliver_signup_thanks(@user_mail,@user,@activation_code)
@user.save!
     #redirect_to :action => 'welcome', :id=>session[:old_id] 
  #   session[:user_id] =@user.id
  #   session[:username] =@user.login
     redirect_to :action => 'welcome', :controller=>'subscribe', :id=>@user.id , :is_a=> 'Subscriber'

rescue Net::SMTPFatalError
flash[:notice] = "ERROR:　There was a problem with sending to that mail address - either the email is incorrect or your internet connection failed. " 
render :action => 'sign_up', :controller=>'subscribe', :id=>@user.id, :user=>@user
rescue Net::SMTPSyntaxError
@user.errors.add(:email, "Problem email address"[])
render :action => 'sign_up', :controller=>'subscribe', :id=>@user.id, :user=>@user
rescue ActiveRecord::RecordInvalid
   flash[:notice] = @errors+ "ERROR: That login already exists." 
     render :action => 'sign_up', :controller=>'subscribe', :id=>@user.id, :user=>@user
end



def login
flash[:notice] ="xx"
self.current_user.forget_me if logged_in?
cookies.delete :auth_token
reset_session
return unless request.post?
#@who=params[:login]
#if User.exists?(:login => {params[:login]})
#flash[:notice] = "User does not exist"[] 
#flash[:notice] = "xxLogged in successfully"[]
current_user = User.authenticate(params[:login], params[:password])
      
if params[:remember_me] == "1"
self.current_user.remember_me
cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
end

# if account is not activted user will be in Invite table
if Invite.exists?(:invite_email => params[:login]) 
@invite=Invite.find_by_invite_email(params[:login])
flash[:notice] = "Not activated"[]
#@user_activate=user
redirect_to :action => 'not_activated', :id=>@invite
return
end
user=User.find_by_login(params[:login])
@user=user
if @user
if @user.confirmed 
session[:username] = params[:login]
session[:role]=user.organisation
session[:user_id]=@user.id
cookies[:user_id] = {:value =>session[:user_id], :expires => Time.now + 1.year }
cookies[:username] = {:value =>session[:username], :expires => Time.now + 1.year }
cookies[:role] = {:value =>session[:role], :expires => Time.now + 1.year}
session[:away]="0"
@user.last_login=Time.now()
@user.update
if session[:role]=="Admin" or session[:role]=="Contributor"
  flash[:notice] = "member"[] 
redirect_back_or_default(:controller => 'message', :action => 'hello') 
else
flash[:notice] = "Logged in successfully"[]
redirect_back_or_default(:controller => 'front', :action => 'index')
end
flash[:notice] = "Logged in successfully"[]
else
self.current_user.forget_me if logged_in?
flash[:notice] = "Not activated"[]
@user_activate=@user
redirect_to :action => 'not_activated', :id=>@user.id
end
else
flash[:notice] = "No such user"[]	
#@user.errors.add (:email, "Username does not exist"[])
end
end  

def logout
  user=User.find(session[:user_id])
  user.login_token=nil
  user.last_login =Time.now()
  user.save
self.current_user.forget_me if logged_in?
cookies.delete :auth_token
cookies.delete :login
#session.delete :user_id
#cookies[:login]=nil
#self.current_user.forget_me if logged_in?
cookies.delete :auth_token
cookies.delete :user_id
cookies.delete :username
cookies.delete :role
#session[:role]=nil
#session[:user_id]=nil
#session[:active]=nil
#session.delete :user_id
#session.delete :username
#session.delete :language
#session.delete :role
#if session[:user_id]
#session[:user_id].delete 
#end
reset_session
#reset_session
flash[:notice] = "Logged out"[]
redirect_back_or_default(:controller => '/front', :action=>'index')
end


def modify_user
if !session[:username]
flash[:notice] = "Please login to continue"[]
redirect_to :action => 'login'
else
@user= User.find(params[:id])
# @user.sections= Section.find(@params[:section_ids]) if @params[:section_ids]
        @updated_user=params[:user]
        if @user.update_attributes(@updated_user)
        flash[:notice] = "Modified User: "+ @user.login
         redirect_to :action => 'signup', :id=>session[:old_id]
       else
  flash[:notice] = "Problem"[]
            redirect_to :action => 'edit', :id=>params[:id]
            end
               end
  end

def not_activated
  @user=User.find(params[:id])
end

def resend_activation_mail
if params[:is_a]=="Subscriber"
	@user = User.find(params[:id])
if @user.confirmed 
flash[:notice] = "Already activated"[]
redirect_to :controller=>'front' 
else
@user_email= @user.fullname + "<" + @user.email + ">"
Notifier.queue=false
Notifier::deliver_resend_activation(@user, @user.activation_code,  @user_email)
flash[:notice] = "Activation resent"[]
redirect_to :action => 'welcome', :controller=>'subscribe', :id=>params[:id], :is_a=>params[:is_a]
return
end

else
	 @invite = Invite.find(params[:id])
@user_email= @invite.fullname + "<" + @invite.invite_email + ">"
	Notifier.queue=false
	Notifier::deliver_resend_activation(@invite, @invite.activation_code, @user_email)
	flash[:notice] = "Activation resent"[]
	redirect_to :action => 'welcome', :controller=>'subscribe', :id=>params[:id], :is_a=>params[:is_a]
	return
	
	
end

rescue Net::SMTPFatalError
flash[:notice] = "ERROR:　There was a problem with that mail address - please check to see it is correct. " 
render :action => 'sign_up', :controller=>'subscribe', :id=>@user.id, :user=>@user
#rescue ActiveRecord::RecordNotFound
#flash[:notice] = "There was a problem."
#render :action => 'welcome', :controller=>'subscribe'

end




def sign_up
if session[:role] or session[:user_id] 
  flash[:notice] = "You have already subscribed."[]
redirect_to :controller=>'front'
else
@lang=params[:lang]
end
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

def your_preferences
  if session[:user_id] 
   @user = User.find(session[:user_id])
 else
   redirect_to :action => 'login'
end
end

  def welcome
@lang=params[:lang]

  end

 

end