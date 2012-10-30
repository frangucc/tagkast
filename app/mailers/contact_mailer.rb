class ContactMailer < ActionMailer::Base
  default from: 'tagkast@poggled.com'

  def contact(name, email, what)
    subject = "Contact requested from Tagkast"
    @name = name
    @email = email
    @what = what
    recipients = ['joe@poggled.com', 'frank@poggled.com', 'jonathan.amir@poggled.com']
    mail(:to => recipients, :subject => subject)
  end
end

