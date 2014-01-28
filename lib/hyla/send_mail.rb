module Hyla
  class Sendmail

    require 'mail'
    require 'mime/types'

    SENDER = 'Charles Moulliard <ch007m@gmail.com>'
    # RECIPIENTS = 'cmoulliard@redhat.com'
    # RECIPIENTS = 'ch007m@gmail.com'
    RECIPIENTS = 'gpe-tech@redhat.com,cmoulliard@redhat.com'
    BODY =  "<H1>Weekly Report Attached as HTML file to this email</H2>\n\r"
    SUBJECT = 'Weekly Report\'s Charles - 13 to 17 January 2014'

    ROOT_DIR = '/Users/chmoulli/RedHat/GPE/Admin/Status-Report/2014/generated_content/'
    fileName = "chm-status-weeks-1301-1701.html"

    FILE_LOCATION = [ROOT_DIR, fileName] * '/'

    mail = Mail.new do
      to      RECIPIENTS
      from    SENDER
      subject SUBJECT
    end

    data = File.read(FILE_LOCATION)

    html_part = Mail::Part.new do
      content_type               'text/html; charset=UTF-8'
      content_transfer_encoding  'quoted-printable'
      body                       BODY
    end

    mail.html_part = html_part
    mail.attachments[fileName] = {
        :mime_type   => 'application/x-html',
        :content     => data }

    mail.delivery_method :smtp,
                         :address          => 'int-mx.corp.redhat.com',
                         :domain           => 'RedHat-MacBook.local',
                         :port             => 25,
                         :enable_starttls  => true,
                         :openssl_verify_mode  => 'none'

    mail.deliver!
    print "Email send to server from #{SENDER} corresponding to #{SUBJECT}"
  end
end