#for this program to run, you need python and sengrid account and the api key set up.
#this needs to be located in python folder for it to be called by cmp + usable with lv program

import os
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

message = Mail(
    from_email=  input('Insert From Email: '),
    to_emails= input('Insert To Email: '),
    subject= input('Insert Subject: '),
    html_content= input('Insert Message: '),)
try:
    sg = SendGridAPIClient(os.environ.get('SENDGRID_API_KEY'))
    response = sg.send(message)
    print(response.status_code)
    print(response.body)
    print(response.headers)
except Exception as e:
    print(e.message)