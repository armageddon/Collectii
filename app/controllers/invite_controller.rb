class InviteController < ApplicationController
  observer :user_observer
  #before_filter :refresh_user_from_cookie
  before_filter :check_session
   before_filter :checklogin, :except=>['welcome', 'activate', 'activate_invite']
  


def check_session
     if !cookies[:login].nil? 
user = User.find_by_login_token(cookies[:login])
       # flash[:notice]= "xxx: "+ cookies[:login]
       if !user.nil?
       session[:user] = user
       session[:user_id] = user.id
       session[:username] = user.login
       session[:lang] = user.language

       if session[:lang]== "eng"
              Gibberish.current_language = :en

           else
       	session[:lang]="jp"

          Gibberish.current_language = :jp
           end
   else
   session[:user_id]=nil
     end

     end
   end  
  
def checklogin
if !session[:user_id] or cookies[:user_id]
flash[:notice] = 'Please login to continue' [] 
redirect_to(:action => 'login', :controller=>'front') 
else
if cookies[:user_id]
 session[:user_id] = cookies[:user_id] 
  session[:username] = cookies[:username] 
   session[:role] = cookies[:role] 
 end
end
end

def activate
	 flash.clear
	 session[:active]=true
if (params[:activation_code] or session[:activation_code]) and Invite.exists?(:activation_code => params[:activation_code])
@user=User.new() 
session[:activation_code]=params[:activation_code]
@invite= Invite.find_by_activation_code(params[:activation_code])
if !session[:lang]
if@invite.invite_language == "eng"
          Gibberish.current_language = :en
   session[:lang]="eng" 
       else
   	session[:lang]="jp"
      Gibberish.current_language = :jp
       end
  
end 
  cookies[:language] = { :value => session[:lang], :expires => Time.now + 1.year}
 session[:active]=true
 
else
	flash[:notice] = 'There was a problem with your account activation. Try logging in.<br>If the problem persists, please contact technical support.' [] 
redirect_to (:action => 'index', :controller=>'front') 
#end
end
end
  
def activate_invite
if params[:activation_code]
@invitee = Invite.find_by_activation_code(params[:activation_code]) 

if @invitee
session[:active]=false
@user = User.new()
@user.unsubscribe_code=User.get_unsubscribe_code
@user.login= params[:invite][:invite_email].strip
@user.email= params[:invite][:invite_email].strip
@user.unsubscribe_code=User.get_unsubscribe_code
@user.fullname=params[:invite][:invite_name].strip
@user.invitee=@invitee.user_id
@user.last_login=Time.now()
@user.activated_at=Time.now()
#if@invitee.invite_language == "eng"
#Gibberish.current_language = :en
#session[:lang]="eng" 
 #   else
	#session[:lang]="jp"
#Gibberish.current_language = :jp
 #   end
#cookies[:language] = { :value => @invitee.invite_language, :expires => Time.now + 1.year} 

@user.password = params[:user][:password]
@user.password_confirmation=params[:user][:password_confirmation]
@user.confirmed=true
@user.organisation="Subscriber"
#if @user.save

@events=Event.find_weekly_from_now
@events2=Event.find(:all)

if @events2.length>@events.length
more = true
end

@timeframe = Event.get_timeframe
#@timeframe_j = @event_date.localize("%A %d %B") + " - " +  @eow.localize("%A %d %B")
@user_email= @user.login + "<" + @user.login + ">"
if @user.valid?
Notifier.queue=false
Notifier::deliver_activation_thanks(@user_email,@user,@events, @timeframe)
end
#add as user and mark subscriber as activated
if @user.save!
flash[:notice] = "Your account has been activated"[] 

@invitee.activation_code=""
@invitee.accepted=true
@invitee.destroy
#login
@current_user = User.authenticate(params[:invite][:invite_email].strip, params[:invite][:password])
session[:user_id] =@user.id
session[:username] =@user.login
session[:role] =@user.organisation
session[:active]=nil

login_token = @user.generate_login_token
@user.update_attribute(:login_token, login_token)
cookies[:login] = { :value => login_token, :expires => Time.now.next_year}

#cookies[:user_id] = {:value =>session[:user_id] }
#cookies[:username] = {:value =>session[:username] }
#cookies[:role] = {:value =>session[:role]}
redirect_to :action => 'welcome', :controller=>'invite'
end

end # end invitee
end # end activation
rescue ActiveRecord::RecordInvalid
#flash[:notice] = "There was a problem."
@invite = Invite.find_by_activation_code(params[:activation_code]) 

render :action => 'activate', :controller=>'invite', :activation_code=>params[:activation_code], :invite=>@invite


end
    
def index
  flash.clear
    @invite = Invite.new(params[:user])
 @user= User.find(session[:user_id])
    @invites_left = @user.invites
if  session[:lang]=="jp"
 @invite.invite_language="jp"
  else 
  @invite.invite_language="eng"
end
end
  
def invite
flash.clear
    @user= User.find(session[:user_id])
    @invites_left = @user.invites
    @invite=Invite.new()
    @invite.user_id=@user.id
    @invite.invite_date=Time.now()

@invite.invite_language=params[:invite][:invite_language]
   @invite.invite_name=params[:invite][:invite_name]
   @invite.invite_email=params[:invite][:invite_email].strip


   ########################
 # email exists as user 
if User.find(:all, :conditions=>["email=?", @invite.invite_email]).length>0 or  User.find(:all, :conditions=>["login=?", @invite.invite_email]).length>0
   @invite.errors.add (:invite_email, "This user already exists")
   #flash[:notice] = "<div id='red'>ERROR: Email " + @user.email + " already exists - meaning the person is already a subscriber.</div>"
     # if session[:role]!="Admin" and session[:role]!="Contributor"
render :action => 'index', :locals =>{:invite=>@invite}  
return
end
    # email exists as invite
if Invite.find(:all, :conditions=>["invite_email=?", @invite.invite_email]).length>0 
   @invite.errors.add (:invite_email, "This user has already been invited")
   #flash[:notice] = "<div id='red'>ERROR: Email " + @user.email + " already exists - meaning the person is already a subscriber.</div>"
     # if session[:role]!="Admin" and session[:role]!="Contributor"
   render :action => 'index', :locals =>{:invite=>@invite}  
   return
end

if Invite.find(:all, :conditions=>["invite_email=?", @invite.invite_email]).length>0
   @invite.errors.add (:invite_email, "This person has already been invited")
   render :action => 'index', :locals =>{:invite=>@invite}  
   return
end
     
@invite.activation_code=Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )

if @invite.errors.empty?  
    # successfully saved with no errors
    if params[:anon]=="1"
      @invitee="the Hyptyo team"
    else
      @invitee=@user.fullname
    end
     
Notifier.queue=false
if @invite.save! and Notifier::deliver_invite_someone(@invite,@invitee, @invite.invite_language)

if @user.organisation=="Subscriber"
@user.invites=@user.invites-1
    end
      @user.update
      @invites_left = @user.invites
   render :action => 'invite', :locals =>{:invite=>@invite}
   return

  #else
    # Errors occurred, redirect to form
  
  #  flash[:notice] = "Your invitation has been sent"
  #  render :action => 'invite', :locals =>{:invite=>@invite} 
end 
end  

########################
rescue ActiveRecord::RecordInvalid
flash[:notice] = "There was a problem."
render :action => 'index', :controller=>'invite'

rescue Net::SMTPFatalError
      @invite.errors.add (:invite_email, "Problem email address"[])
      # flash[:notice] = "ERROR:　There was a problem with that mail address - please check to see it is correct. " 
       #@user.email=@invite.invite_email
       #@user.login=@invite.invite_name
       render :action => 'index'
       
rescue Net::SMTPSyntaxError
             @invite.errors.add (:invite_email, "Problem email address"[])
             # flash[:notice] = "ERROR:　There was a problem with that mail address - please check to see it is correct. " 
              #@user.email=@invite.invite_email
              #@user.login=@invite.invite_name
              render :action => 'index'
end

end