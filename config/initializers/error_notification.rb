#Add email address where you want error notifications sent to.  Add the email address in between the parentheses %w()
#ExceptionNotification::Notifier.exception_recipients = %w(user@email.edu)
 
 ExceptionNotification::Notifier.exception_recipients = %w(admin_email@yourdomain.edu)
 ExceptionNotification::Notifier.email_prefix = "[Library a la Carte Error] "
