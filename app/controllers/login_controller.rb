
class LoginController < ApplicationController


  
  #layout "admin"  
  
#before_filter :make_activation_code, :only=>['add_user']
  
#  before_filter :authorize, :except => :login
  # . . 

  def add_user
  @user = User.new
  @profile = Profile.new
  @profile.user_id= @user.id
  email=""
  if request.post?
    params[:user][:email]=params[:user][:email].strip
    params[:user][:password]=params[:user][:password].strip
    params[:user][:password_confirmation]=params[:user][:password_confirmation].strip
    params[:user][:name]=params[:user][:display_name]
          @user = User.new(params[:user])

           if @user.save
  flash[:notice] = "Welcome #{@user.name}. Your account has been created.<br> <a href='/user/edit_profile'>Click here</a> to edit your profile."
         # @user = User.new
  session[:user_id] = @user.id
  session[:user_name] = @user.name
          @button= params[:login]
  self.current_user = User.authenticate(params[:name], params[:password])
  redirect_to :action=>'collector', :controller=>'posts', :id => @user.id
  #@user=User.find(params[:email])

  if @button == "Login and Edit Yo]ur Profile"
  redirect_to(:controller => "login", :action => "login")
  else
  #redirect_to(:controller => "login", :action => "login")

    user = User.authenticate(params[:name], params[:password])
    if @user
      @user.signup_date=Time.now
      @user.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) 
 # not sure why this not working
 # Notifier.queue=false
  Notifier::deliver_admin_signup(@user, params[:user][:password],@user.activation_code)
  @user.save!
    session[:user_id] = @user.id
    session[:user_name] = @user.name
  end

  end
  end
  end
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
  
  
  def change_password
      return unless request.post?
      if User.authenticate(user.login, params[:old_password])
        if (params[:password] == params[:password_confirmation])
         user.password_confirmation = params[:password_confirmation]
        user.password = params[:password]
          flash[:notice] = current_user.save ?
                "Password changed" :
                "Password not changed" 
        else
          flash[:notice] = "Password mismatch" 
          @old_password = params[:old_password]
        end
      else
        flash[:notice] = "Wrong password" 
      end
    end
    
  
  def index
   # @total_orders = Order.count
   login
   render :action => 'login'
  end
  

  # just display the form and wait for user to
  # enter a name and password
  
  def login
    @button= params[:login]
if request.post?
  
     authentication
else
session[:user_id] = nil
#if request.get?
      @from = params[:id]
end
  
end
  
def authentication
params[:name]=params[:name].strip
params[:password]=params[:password].strip
user = User.authenticate(params[:name], params[:password])
if user
session[:user_id] = user.id
session[:user_name] = user.name
if @button == "Login and Edit Your Profile"
redirect_to(:action => "edit_profile", :controller=>"user", :id=> params[:id])
elsif params[:action]  =='login' or params[:action]=='add_user'
  #redirect_to(session[:referer]) 
  redirect_to :action=>'collector', :controller=>'posts', :id=>user
end
#redirect_to(session[:referer]) 
#redirect_to :action=>'collector', :controller=>'posts', :id=>user
#end
else
flash[:notice] = "Invalid user/password combination" 
redirect_to(:action => "login", :controller=>"login", :login=>@button)
end 
end



    def update
     # @user = User.find(params[:id])
      @user.name=@user_name
      @user = User.find(@user_id)
      @profile = Profile.find_by_user_id(@user_id)
     if @profile.update_attributes(@profile.id)
#@user.save
        flash[:notice] = 'Your profile has been modified.'
      redirect_to :action => 'profile', :id => @user_id
#else
   #   redirect_to :action => 'profile', :id => @user_id
end
    end

    def edit_user
      id = params[:id]
      @user=User.find(id)
    end

    
    def delete_user
      id = params[:id]
      if id && user = User.find(id)
        begin
          user.safe_delete
          flash[:notice] = "User #{user.name} deleted"
        rescue Exception => e
          flash[:notice] = e.message
        end
      end
      redirect_to(:action => :list_users)
    end

    def list_users
      @all_users = User.find(:all)
    end

    def logout
        if request.get?
        @from = params[:id]
        session[:referer] = request.referer 
        @referer=session[:referer]
      end
      #session[:user_id] = nil
      #session[:user_name] = nil
      #session[:referer] = nil
      reset_session 
      session[:referer] = request.referer 
     redirect_to(:action => "login", :controller=> "login")
      #redirect_to(:action => "list", :controller=> "posts")
      #redirect_to(session[:referer])
       flash[:notice] = "You have sucessfully logged out" 
    end

   # def make_activation_code
  #  @activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
   # end

  end