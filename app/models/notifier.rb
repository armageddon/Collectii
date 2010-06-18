class Notifier < ActionMailer::Base

def signup_thanks(user_email, user, activation_code)
    s = StringScanner.new(user_email)
    if s.exist? /hotmail/ and user.language =="jp"
       @charset = "EUC"
         	@from  = "info@hyptyo.com"
       elsif s.exist? /yahoo/
       @charset = "ISO Latin 1"
       	@from  = "info@hyptyo.com"
      else
       @from  = "hyptyo@hyptyo.com"
       @charset = "utf-8"
    end
    		#@recipients = "tshirtmaker@radarboy.com"
    		@recipients = user_email
    	
    		@subject = 'HYPTYO. Please activate your account.'
    @body["user"]=user
end
  

def apb(user_email, msg)
s = StringScanner.new(user_email)
#if s.exist? /hotmail/
#       @charset = "EUC"
#end
		@recipients = user_email
		@from  = "hyptyo@hyptyo.com"
		@subject = 'HYPTYO. Alert.'
@body["msg"]=msg
end


def user_details(user)
s = StringScanner.new(user.email)
if s.exist? /hotmail/ and user.language=="jp"
         @charset = "EUC"
         else
          @from  = "hyptyo@hyptyo.com"
          @charset = "utf-8"
end
    		#@recipients = "tshirtmaker@radarboy.com"
    		@recipients = user.email
    		@from  = "hyptyo@hyptyo.com"
    		@subject = 'HYPTYO. Account Details.'
    @body["user"]=user
end
  
def admin_signup(user, pw, activation_code)
       s = StringScanner.new(user.email)
      if s.exist? /hotmail/ and user.language=="jp"
          @charset = "EUC"
          else
           @from  = "info@radarboy.com"
           @charset = "utf-8"
       end
    		#@recipients = "tshirtmaker@radarboy.com"
    		@recipients = user.email
    		@from  = "info@radarboy.com"

#if user.organisation=="Contributor" 
    		  @subject="Welcome to Collectii"
#elsif user.organisation=="Subscriber" 
#@subject="SUBSCRIBER"
 #   		  else 
 #   		  @subject="ADMINISTRATOR"
#end
# @subject = 'Your have been invited to be Hyptyo '+ @subject
    @body["user"]=user
    @body["pw"]=pw
    @body["activation_code"]=activation_code
   # @body["invitee"]=invitee
end
  
def resend_activation(user, activation_code, to_who)
     s = StringScanner.new(to_who)
   if s.exist? /hotmail/ and user.language=="jp"
       @charset = "EUC"
       else
        @from  = "hyptyo@hyptyo.com"
        @charset = "utf-8"
    end
  		#@recipients = "tshirtmaker@radarboy.com"
@recipients = to_who
@from  = "hyptyo@hyptyo.com"
@subject = 'HYPTYO. Please activate your account.'
@body["user"]=user
@body["activation_code"]=activation_code

end
  
def activation_thanks(user_email,user)
     s = StringScanner.new(user_email)
   if s.exist? /hotmail/ and user.language =="jp"
       @charset = "EUC"
       else
        @from  = "hyptyo@hyptyo.com"
        @charset = "utf-8"
    end
  		#@recipients = "tshirtmaker@radarboy.com"
  		@recipients = user_email
  		@from  = "info@radarboy.com"
  		@subject = 'Welcome to the Collectii family.'
@body["user"]=user
#@body["events"]=events
#@body["timeframe"]=timeframe

end

def mailing_list(user_email,user, events,timeframe, subj, msg)
s = StringScanner.new(user_email)
if s.exist? /hotmail/ and user.language =="jp"
@charset = "EUC"
@from  = "info@hyptyo.com"
else
@from  = "hyptyo@hyptyo.com"
@charset = "utf-8"
end
@recipients = user_email
@subject = 'HYPTYO. '+subj
@body["user"]=user
@body["msg"]=msg
@body["events"]=events
@body["timeframe"]=timeframe

end


def admin_warning

	@recipients = "george@hyptyo.com, mrjinki1@gmail.com"
	@from  = "hyptyo@hyptyo.com"
	    @subject  = 'ADMIN ALERT - mail queue stuck'
	@body = "Wild eep! This is a general notice to tell you the mail queue is stuck, due to a corrupt email address, but should resume in the next 10 minute cycle. Ignore this message unless you get a stream of them. "
 for reject in RejectedMail.find(:all)
@body += reject.object
end
end

def invite_someone(invite, invitee, lang)
     s = StringScanner.new(invite.invite_email)
      if s.exist? /hotmail.co.jp/ and invite.invite_language =="jp"
          @charset = "EUC"
            	@from  = "info@hyptyo.com"
          elsif s.exist? /yahoo/
          @charset = "utf-8"
          @from  = "info@hyptyo.com"
        	else
       @from  = "hyptyo@hyptyo.com"
       @charset = "utf-8"
    end
    @recipients = invite.invite_email
  
    @subject = 'You have been invited to join Hyptyo'
@body["invite"]=invite
@body["invitee"]=invitee
@body["lang"]=lang
end
  
def invitee_thanks(user,body)
     s = StringScanner.new(user)
   if s.exist? /hotmail/ and user.language=="jp"
       @charset = "EUC"
       	@from  = "info@hyptyo.com"
       else
       @from  = "hyptyo@hyptyo.com"
       @charset = "utf-8"
    end
		#@recipients = "tshirtmaker@radarboy.com"
		@recipients = user
	
		@subject = 'Hyptyo. Your account has been activated.'

  	@body = body
end
  
def forgot_password(user)
     s = StringScanner.new(user.email)
   if s.exist? /hotmail/
       @charset = "EUC"
       else
        @from  = "hyptyo@hyptyo.com"
        @charset = "utf-8"
    end
@recipients = user.email
@from  = "hyptyo@hyptyo.com"
    @subject  = 'HYPTYO. Request to change your password'
@body["user"]=user
@body[:url2]  = "http://localhost:3005/front/reset_password/#{user.password_reset_code}" 
@body[:url]  = "http://www.hyptyo.com/front/reset_password/#{user.password_reset_code}" 
end

def reset_password(user, password)
      s = StringScanner.new(user.email)
    if s.exist? /hotmail/
        @charset = "EUC"
        else
         @from  = "hyptyo@hyptyo.com"
         @charset = "utf-8"
     end
@recipients = user.email
@from  = "hyptyo@hyptyo.com"
@subject = 'HYPTYO. Your password has been reset'
@body["user"]=user
@body["password"]=password
  end

end