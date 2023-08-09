#for this program to run, you need python and sengrid account and the api key should be set up in your os environment
#see: https://labjack.com/pages/support/?doc=/app-notes/networking/sending-emails-from-a-program/#header-three-pojeq
#this needs to be located in python folder for it to be called by command prompt + usable with lv program
import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

#collect user input for email details
message = Mail(
    from_email=  input('Insert From Email: '),
    to_emails= input('Insert To Email: '),
    subject= input('Insert Subject: '),
    html_content= input('Insert Message: '),
    api_key= input('Provide your API Key: '),)

#send the email
try:
    sg = SendGridAPIClient(os.environ.get(api_key))
    response = sg.send(message)
    print(response.status_code)
    print(response.body)
    print(response.headers)
except Exception as e:
    print(e.message)
