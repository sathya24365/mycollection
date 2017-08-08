#!/usr/bin/python

# Kevin Degi was kind enough to provide the PRISM team with a Python sample in calling PRISM web service.
# This script first calls GetChangeRequestById() to get the contents of a CR. It then
# appends the word 'TEST' to the description and saves the CR.
import csv
import datetime
from datetime import tzinfo
import urllib2

from ntlm import HTTPNtlmAuthHandler
from suds.client import Client
from suds.transport import http
from suds.transport.https import WindowsHttpAuthenticated

import re
from datetime import *
import logging

#logging.basicConfig(level=logging.INFO)
#logging.getLogger('suds').setLevel(logging.DEBUG)

class Prism:
  def __init__(self, url, user, passwd):
    self.url = url  
    #print user
    user = 'na\\' + user
    self.client = Client(url, transport=WindowsHttpAuthenticated(username=user, password=passwd))

    #print  self.client
    
  def getChangeRequestIsCrashById(self, key):
    #print  self.client
    #print key
    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response = self.client.service.GetChangeRequestById([request])
    #print response
    return (response['ChangeRequest']['IsCrash'], \
            response['ChangeRequest']['CreatedDate'])
    
  def getChangeRequestDateFA(self, key):
    #print  self.client
    #print key
    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response = self.client.service.GetChangeRequestById([request])
    #print response
    
    
    for part in response['ChangeRequest']['Participants']['Participant']:
      if part['IsPrimary'] == True:
        return (response['ChangeRequest']['CreatedDate'], \
                part['SwFunctionality'])

    #return (response['ChangeRequest']['CreatedDate'], \
            #response['ChangeRequest']['Participants']['ParticipantEntity'][0]['SwFunctionality'])
                  
    
  def getChangeRequestById(self, key):
    #print  self.client

    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response = self.client.service.GetChangeRequestById([request])
    #print response
    
    #print response['Participants']
    #print response['ChangeRequest']['Participants']['ParticipantEntity']
    #print response['ChangeRequest']['Participants']['ParticipantEntity'][0]['SubSystem']
    for part in response['ChangeRequest']['Participants']['Participant']:
      if part['IsPrimary'] == True:
        return (part['Area'], part['SubSystem'], part['SwFunctionality'])

  def saveChangeRequest(self, CR):
    request = self.soapclient.factory.create('ns5:SaveCRRequest')
    request['ChangeRequest'] = CR
    request['UserName'] = 'admin'
    response = self.soapclient.service.SaveChangeRequest([request])
    return response['ChangeRequestId']

  def editObject(self, obj, **kwargs):
    for key, value in kwargs.iteritems():
      if key in obj:
        obj[key] = value
    return obj

  def updateChangeRequest(self, CR, **kwargs):
    newCR=editObject(CR, kwargs)
    saveChangeRequest(newCR)

  def updateChangeRequestById(self, CRkey, **kwargs):
    CR = getChangeRequestById(CRkey)
    return updateChangeRequest(CR, kwargs)
  def getChangeRequestTitle(self, key):
    #print  self.client

    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response = self.client.service.GetChangeRequestById([request])
    
    return (response['ChangeRequest']["Title"])
  def getChangeRequestDetails(self,key):
    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response=None
    try:
        response = self.client.service.GetChangeRequestById([request])
    except:
        pass
    if response is not None:
    #response = self.client.service.GetChangeRequestById(request)
        for part in response['ChangeRequest']['Participants']['Participant']:
            if part['IsPrimary'] == True:
			    return (response['ChangeRequest']["Title"],part['Area'], part['SubSystem'], part['SwFunctionality'])
    else:
        return ('Update manually','None','None','None')
            
  def getChangeRequestDetailsDateStatus(self,key):
    request = self.client.factory.create('ns1:CRRequest')
    request['ChangeRequestId'] = key
    #print key
    response = self.client.service.GetChangeRequestById([request])
    for part in response['ChangeRequest']['Participants']['Participant']:
      if part['IsPrimary'] == True:
        return (response['ChangeRequest']["Status"],response['ChangeRequest']["CreatedDate"],part['Area'], part['SubSystem'], part['SwFunctionality'],response['ChangeRequest']["Title"])



if __name__ == '__main__':

  import getpass
    #os.getlogin()
    #if len(user) is 0:
    #user = getpass.getuser()
  #user = raw_input("Username:")
   #print "Username: " + user
  #pw = getpass.getpass()
  user = "unagi"
  pw = "Fishhead89"
 #prism = Prism('http://qctprismbeta:8000/ChangeRequestWebService.svc?wsdl', user, pw)
  prism = Prism('http://prism:8000/ChangeRequestWebService.svc?wsdl',user, pw)
  #CR = prism.getChangeRequestById('555274')
  #CR = ['538136','524256','491554','524821']
  #CRcrash = prism.getChangeRequestIsCrashById('555274')
  (create, fa) = prism.getChangeRequestDateFA('580154')
  #zone = 'America/Los_Angeles'
  create = create-timedelta(hours=7)
  print create, fa
  #print CRcrash

  #CR['Description'] = CR['Description'] + 'TEST'
  #retval = prism.saveChangeRequest(CR)
  #print retval