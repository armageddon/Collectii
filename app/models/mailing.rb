class Mailing < ActionMailer::Base
   def mailing(send_to, name, title, my_body, sent_at = Time.now)
      recipients  send_to
      subject     "Signup Mail for: #{name}"
      from = 'someonone@example.com'

      @title      = title
      body       = body
      @recipients = recipient
      @from       = 'someone@example.com'
      @sent_on    = sent_at
      @headers    = {}
    end
end
