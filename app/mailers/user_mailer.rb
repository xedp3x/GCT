class UserMailer < ActionMailer::Base
  default from: YAML.load(File.open('config/gct.yml'))['site']['mail']
  def reset_email(person)
    @person = person
    @host = YAML.load(File.open('config/gct.yml'))['site']['host']
    @link = url_for host: "www.#{@host}", controller: :user, action: :token, uid: @person.id, time: Time.now.to_i, token: Base64.encode64(Digest::MD5.digest("#{Time.now.to_i}#{@person.userPassword}")).gsub('/','|')
    mail(to: @person.mail, subject: "Password reset for #{@host}")
  end
end
