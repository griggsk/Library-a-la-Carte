#Library a la Carte Tool (TM).
#Copyright (C) 2007 Oregon State University
#See license-notice.txt for full license notice

class Notifications < ActionMailer::Base
  
  def forgot_password(to, pass, sent_at = Time.now)
    @subject    = "Library a la Carte Message"
    @body['pass']= pass
    @recipients = to
    @from       = ""
    @sent_on    = sent_at
    @headers    = {}
  end
  
   def forgot(to, onid, section,url, sent_at = Time.now)
    @subject    = "Library Tutorial Message"
    @body['onid']= onid
    @body['sect']= section
    @body['url']= url
    @recipients = to
    @from       = ""
    @sent_on    = sent_at
    @headers    = {}
  end
  
   def send_url(to, from, body,  sent_at = Time.now)
    @subject    = "Library Course Page Announcement"
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_tutorial(to, from, body, sent_at = Time.now)
    @subject    = "Shared Library a la Carte Tutorial"
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
   def send_all(to, from, subject, body,  sent_at = Time.now)
    @subject    = subject
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_page(to, from, body, sent_at = Time.now)
    @subject    = "Shared Library a la Carte Course Page"
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_guide(to, from, body, sent_at = Time.now)
    @subject    = "Shared Library a la Carte Subject Guide"
    @body['body']= body
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_module(to, from, mod,name, sent_at = Time.now)
    @subject    = "Shared Library a la Carte Module"
    @body['mod']=mod
    @body['name']=name
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def add_user(to, from, pass, url, sent_at = Time.now)
    @subject    = "Library ala Carte Message"
    @body['pass']=pass
    @body['email']=to
    @body['url']=url
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def add_pending_user(to, from, sent_at = Time.now)
    @subject    = "Library ala Carte Message"
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {} 
  end
  
  def accept_pending_user(to, from, pass, url, sent_at = Time.now)
    @subject    = "Your Library ala Carte Account has been approved"
    @body['pass']= pass
    @body['email']= to
    @body['url']= url
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}  
  end
 
  def accept_nonsso_pending_user(to, from, pass, url, sent_at = Time.now)
    @subject    = "Your Library ala Carte Account has been approved"
    @body['pass']= pass
    @body['email']= to
    @body['url']= url
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}  
  end
  
  def reject_pending_user(to, from, sent_at = Time.now)
    @subject    = "Your Library ala Carte Account has been denied"
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}  
  end
  
    def notify_admin_about_pending_user(to, from, url, sent_at = Time.now)
    @subject    = "Library ala Carte Message - Pending User Notification"
    @body['url']= url
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}  
  end
end
