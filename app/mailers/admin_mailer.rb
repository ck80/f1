class AdminMailer < Devise::Mailer
  default from: 'f1tips@agoralogic.com'
  layout 'mailer'

  def new_user_waiting_for_approval(email)
    @email = email
    mail(to: 'f1tips@agoralogic.com', subject: 'New User Awaiting Admin Approval')
  end

end