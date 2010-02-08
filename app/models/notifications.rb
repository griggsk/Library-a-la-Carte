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
    @subject    = "Shared Tutorial Message"
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
  
  def share_page(to, from, page,name, sent_at = Time.now)
    @subject    = "Shared Course Page Message"
    @body['page']=page
    @body['name']=name
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_guide(to, from, guide,name, sent_at = Time.now)
    @subject    = "Shared Subject Guide Message"
    @body['guide']=guide
    @body['name']=name
    @recipients = to
    @from       = from
    @sent_on    = sent_at
    @headers    = {}
  end
  
  def share_module(to, from, mod,name, sent_at = Time.now)
    @subject    = "Shared Module Message"
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
  
  
end
