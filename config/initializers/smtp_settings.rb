#Select delivery method - Defines a delivery method. 
  #Possible values are :smtp (default), :sendmail, and :test. 

#Add your settings
# smtp_settings - Allows detailed configuration for :smtp delivery method:

   # * :address - Allows you to use a remote mail server. Just change it from its default "localhost" setting.
   # * :port - On the off chance that your mail server doesnÔt run on port 25, you can change it.
   # * :domain - If you need to specify a HELO domain, you can do it here.
   # * :user_name - If your mail server requires authentication, set the username in this setting.
   # * :password - If your mail server requires authentication, set the password in this setting.
   # * :authentication - If your mail server requires authentication, you need to specify the authentication type here. This is a symbol and one of :plain, :login, :cram_md5.
   # * :enable_starttls_auto - When set to true, detects if STARTTLS is enabled in your SMTP server and starts to use it. It works only on Ruby >= 1.8.7 and Ruby >= 1.9. Default is true.

# sendmail_settings - Allows you to override options for the :sendmail delivery method.

#    * :location - The location of the sendmail executable. Defaults to /usr/sbin/sendmail.
#    * :arguments - The command line arguments. Defaults to -i -t.


#smtp example
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "localhost",
  :port => 25,
  :domain => "library.yourdomain.edu"
} 