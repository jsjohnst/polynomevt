class Emailer < ActionMailer::Base
  def credentials(recipient, login, password, sent_at = Time.now)
    @subject = 'Polynome - Lost credentials information'
    @recipients = recipient
    @from = 'fhinkel@vt.edu'
    @sent_on = sent_at
    @body["login"] = login
    @body["password"] = password
    @headers = {}
    @headers["x-mailer"] = "Polynome Lost Credentials"
  end
end
