class AccountController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def activate_invite
  cookies[:language] = { :value => params[:lang], :expires => Time.now + 1.year} 
  if params[:activation_code] 
  @user = User.find_by_activation_code(params[:activation_code]) 
    @user.last_login=Time.now()
    @user.activated_at=Time.now()
    @user.confirmed=true
    flash[:notice] = "Your account has been activated." 
    @events=Event.find_weekly_from_now
    @events2=Event.find(:all)
    if @events2.length>@events.length
    more = true
    end
    @user.activation_code=""
    @user.invites=10
    @timeframe = Event.get_timeframe
    #@timeframe_j = @event_date.localize("%A %d %B") + " - " +  @eow.localize("%A %d %B")
    @user_email= @user.login + "<" + @user.email + ">"
  Notifier.queue=false
    Notifier::deliver_activation_thanks(@user_email,@user,@events, @timeframe)
    #Notifier::deliver_user_details(@user)

    @user.save!

    #login
    @current_user = User.authenticate(@user.login, @user.password)
  set_sessions(@user)
    redirect_to :action => 'control', :controller=>'admin'

    end # end activation

  rescue Net::SMTPFatalError
  flash[:notice] = "ERROR:　There was a problem with sending to that mail address - either the email is incorrect or your internet connection failed. " 
  render :action => 'activate', :controller=>'account'
    end




  # say something nice, you goof!  something sweet.
  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      session[:user_id]=self.current_user.id
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/account', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "Log in error"
    end
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
     @user.name = params[:user][:login]
    @user.save!
    self.current_user = @user
    redirect_back_or_default(:controller => '/account', :action => 'index')
    flash[:notice] = "Thanks for signing up!"
    if @pw == params[:user][:password_confirmation]
    Notifier.queue=false
    Notifier::deliver_admin_signup(@user, @pw, @invitee)
    end
            @user.save!
            self.current_user = @user
            redirect_back_or_default(:controller => '/account', :action => 'signup')
            flash[:notice] = "New user signed up!"

    				########################

    rescue Net::SMTPFatalError
    @user.errors.add (:email, "Problem email address"[])
    render :action => 'signup'

    rescue Net::SMTPSyntaxError
    @user.errors.add (:email, "Problem email address"[])
    render :action => 'signup'

    rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => '/account', :action => 'index')
  end
end
