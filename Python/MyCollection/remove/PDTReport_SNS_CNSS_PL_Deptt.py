# This script shows how to connect to a JIRA instance with a
# username and password over HTTP BASIC authentication.


from __future__ import print_function
from jira.client import *
#from prism_report import *
from prism_report_update import *
from collections import defaultdict
from itertools import *
import unicodedata
import time
import sys
import subprocess


FIELDS_CO = 'summary,created,status,resolution,reporter,issuelinks,description'  # COMMON JIRA FIELDS

SERACH_FIELDS = FIELDS_CO + ',' + 'customfield_10032,customfield_10034,customfield_10060,customfield_10933,customfield_10935,customfield_12830,customfield_14929,customfield_14930,customfield_23517,customfield_26413,customfield_26610'  # SEARCH FIELDS

# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Issue Status Definition
customfield_10034 = "customfield_10034"
customfield_10686 = "customfield_10686"
FIELD_SERIAL = "customfield_10842"
FIELD_SERIAL_NUMBER = "customfield_14929"
customfield_10270 = "customfield_10270"
customfield_11063 = "customfield_11063"

#Support for QSTABILITY
FIELD_BUILD_INFO = "customfield_26413"
FIELD_LOGS = "customfield_26610"
FIELD_RESOLUTION_NOTES = "customfield_12830"

FIELD_QNPSTBLT_REFERENCE_TICKET = "customfield_13323"
FIELD_ARAST_METABUILD = "customfield_10933"
FIELD_CRASHLOG_LOCATION = "customfield_10935"

JIRA_QUERY_LINK = """https://jira.qualcomm.com/jira/secure/IssueNavigator.jspa?reset=true&jqlQuery="""
JIRA_TICKET_LINK = """/jira/browse/"""

ISSUE_STATUS_OPEN = "1"
ISSUE_STATUS_IN_PROGRESS = "3"
ISSUE_STATUS_REOPENED = "4"
ISSUE_STATUS_CLOSED = "6"
ISSUE_STATUS_NEW = "10001"
ISSUE_STATUS_ON_HOLD = "10002"
ISSUE_STATUS_NEED_MORE_INFORMATION = "10072"
ISSUE_STATUS_CLOSED_REJECTED = "10014"
ISSUE_STATUS_CLOSED_OVER_2_DAYS = "10074"
ISSUE_STATUS_S2_ANALYSIS = "10060"
ISSUE_STATUS_CLOSED_ROOT_CAUSE_FOUND = "10069"
ISSUE_STATUS_CLOSED_CR_CREATED_BY_S1 = "10070"
ISSUE_STATUS_CLOSED_CR_CREATED_BY_S2 = "10071"
ISSUE_STATUS_CLOSED_ROOT_CAUSE_NOT_FOUND = "10073"
ISSUE_STATUS_TRANSFERRED = "10306"
ISSUE_STATUS_NOT_RELEVANT = "10475"

ISSUE_RESOL_FIXED = "1"
ISSUE_RESOL_WONT_FIXED = "2"
ISSUE_RESOL_DUPLICATE = "3"
ISSUE_RESOL_INCOMPLETE = "4"
ISSUE_RESOL_CANNOT_REPRODUCE = "5"
ISSUE_RESOL_COMPLETE = "6"
ISSUE_RESOL_WITHDRAWN = "7"
ISSUE_RESOL_INVALID = "8"
ISSUE_RESOL_DONE = "9"

DEFAULT_CR_STR = r"No CR Found"
DEFAULT_UNKNOWN_STR = r"Unknown"
QNPSTBLT_DUPLICATION_STR = """Closed because of duplication of https://jira.qualcomm.com/jira/browse/QNPSTBLT"""

MAX_DUPLICATION_DEPTH = 12
MAX_JIRA_ISSUES = 100000
CACHE_RESULTS = True

JIRA_TRANS_STATE_OPEN = "721"
JIRA_TRANS_STATE_TRANSFER = "771"
JIRA_TRANS_STATE_CLOSE = "2"
JIRA_TRANS_STATE_REOPEN = "3"
JIRA_ISSUES_INTERVAL = 1000

# Assume CR number is 6 digits
CR_NUMBER_LENGTH = 6
FileSummary = True
#-------------------------------------------------------------------------------------------------------------------------------------------#


PROJECT = ''
BUILDID = ''

ISSUE_CLOSED = ["Closed", "Transferred"]
ISSUE_RESOLVED = ["Fixed", "Won't Fix", "Duplicate", "Complete", "Done"]

Stability = ["CNSSDEBUG","ARAST", "AVATAR", "AVATARWPAP", "BAGHEERAST", "BLAUNCH",
             "DINOSTABLE", "DROIDBUG", "ELANSTABLE", "FORINO", "FRODOST",
             "FUSIONT", "FUSNFOURST", "JINGALA", "QNPSTBLT", "QSTABILITY",
             "TORINOST", "WAVEAPOLLO", "WCNSTABLE", "WPARAGORN", "WPFRODO", "WRSTABLE"]
PLs =['APQ', 'MSM','MDM','FUSION']

ISS_FIX = ""
RepIssue = []
CR = []
RC = []
uniCR =[]
List_CR = []
Processed = []
listIssue = []
jira = None
loop =0   # added for avoiding strucking in loop for getting issue resolution
Total_issues = 0

PLNAME =''
apss = ''
cnssImage =''
buildID =''
Build_PL = {}
Build_PLAP ={}
Build_PLCN ={}


def getIssueStatus(issue):  # Function to find Issue Status
    if issue.fields.status is None:
        sTatus = "Unknown Status"
    elif issue.fields.status.id == ISSUE_STATUS_OPEN:
        sTatus = "Open"
    elif issue.fields.status.id == ISSUE_STATUS_IN_PROGRESS or \
        issue.fields.status.id == ISSUE_STATUS_S2_ANALYSIS:
        sTatus = "In Progress"
    elif issue.fields.status.id == ISSUE_STATUS_REOPENED:
        sTatus = "Reopened"
    elif issue.fields.status.id == ISSUE_STATUS_CLOSED or \
        issue.fields.status.id == ISSUE_STATUS_CLOSED_ROOT_CAUSE_FOUND or \
        issue.fields.status.id == ISSUE_STATUS_CLOSED_CR_CREATED_BY_S1 or \
        issue.fields.status.id == ISSUE_STATUS_CLOSED_CR_CREATED_BY_S2 or \
        issue.fields.status.id == ISSUE_STATUS_CLOSED_REJECTED or \
        issue.fields.status.id == ISSUE_STATUS_CLOSED_ROOT_CAUSE_NOT_FOUND:
        sTatus = "Closed"
    elif issue.fields.status.id == ISSUE_STATUS_NEW:
        sTatus = "New"
    elif issue.fields.status.id == ISSUE_STATUS_ON_HOLD:
        sTatus = "On Hold"
    elif issue.fields.status.id == ISSUE_STATUS_NEED_MORE_INFORMATION:
        sTatus = "Need More Information"
    elif issue.fields.status.id == ISSUE_STATUS_CLOSED_OVER_2_DAYS:
        sTatus = "Closed Over 2 Days"
    elif issue.fields.status.id == ISSUE_STATUS_TRANSFERRED:
        sTatus = "Transferred"
    else:
        sTatus = "Unknown Status: " + str(issue.fields.status.id)

    return sTatus


def getIssueResolution(issue):  # Function to find Issue resolution
    if issue.fields.resolution is None:
        isuResolution = "Pending"
    elif issue.fields.resolution.id == ISSUE_RESOL_FIXED:
        isuResolution = "Fixed"
    elif issue.fields.resolution.id == ISSUE_RESOL_WONT_FIXED:
        isuResolution = "Won't Fix"
    elif issue.fields.resolution.id == ISSUE_RESOL_DUPLICATE:
        isuResolution = "Duplicate"
    elif issue.fields.resolution.id == ISSUE_RESOL_INCOMPLETE:
        isuResolution = "Incomplete"
    elif issue.fields.resolution.id == ISSUE_RESOL_CANNOT_REPRODUCE:
        isuResolution = "Cannot Reproduce"
    elif issue.fields.resolution.id == ISSUE_RESOL_WITHDRAWN:
        isuResolution = "Withdrawn"
    elif issue.fields.resolution.id == ISSUE_RESOL_COMPLETE:
        isuResolution = "Complete"
    elif issue.fields.resolution.id == ISSUE_RESOL_INVALID:
        isuResolution = "Invalid"
    elif issue.fields.resolution.id == ISSUE_RESOL_DONE:
        isuResolution = "Done"
    else:
        isuResolution = "Unknown Resolution: " + str(issue.fields.resolution.id)

    return isuResolution


def getJiraIssues(jquery):
    startAt =0
    issues = []

    while True:
        jresp = jira.search_issues(jquery, startAt, maxResults=JIRA_ISSUES_INTERVAL, fields=SERACH_FIELDS)
        if jresp is None or len(jresp) == 0:
            break

        startAt += JIRA_ISSUES_INTERVAL
        issues += jresp

        if len(jresp) < JIRA_ISSUES_INTERVAL:
            break

        if len(issues) >= MAX_JIRA_ISSUES:
            print("Reached the maximum: %d" % MAX_JIRA_ISSUES)
            break

        print("Starting at issues: " + str(startAt),end='\r')

    return issues


def issueDFinal(issue):
    issFix = ''
    final =issue.key
    global loop

    if 'QSTABILITY' in final:
        final =issueFinal(issue)
    else:
    
        if loop < 12:
            loop+= 1
            try:
                if issue.fields.customfield_10034 is None:
                    issFix = ''
                else:
                    issFix = issue.fields.customfield_10034
            except:
                pass
            try:

                if issue.fields.customfield_10686 is None:
                    issFix += ''
                else:
                    issFix = issFix + issue.fields.customfield_10686
            except:
                pass
            try:
                if issue.fields.customfield_10270 is None:
                    issFix += ''
                else:
                    issFix = issFix + issue.fields.customfield_10270
            except:
                pass
            try:
                if issue.fields.customfield_11063 is None:
                    issFix += ''
                else:
                    issFix = issFix + issue.fields.customfield_11063
            except:
                pass

            if issFix != '':
                final = issFix.upper()
                if 'CR' in final:
                    finalinter = final[final.rfind('CR'):]
                    finalinter = finalinter.replace('/', '')
                    finalinter =finalinter.strip()
                    finalinter =finalinter[:8]
                    if (finalinter.strip('CR')).isnumeric():
                        final =finalinter
                    else:
                        final=final.lower()
                elif checkStr(final) != 'None':
                    issFix = checkStr(final)
                    final = final[final.rfind(issFix):]
                    final =final.strip()
                    if final == issue.key:
                        final = final
                    else:
                        try:
                            final = issueDFinal(jira.issue(final.replace(' ','')))
                        except:
                            pass
                elif final.isnumeric():
                    final =final.strip()
                    final = 'CR' + final
            else:
                final = checkLinkedIssue(issue)
                if final != '':
                    try:
                        final = issueDFinal(jira.issue(final.replace(' ','')))
                    except:
                        pass
                else:
                    final = issue.key

        loop=0
    return final


def issueRep():
    for m in range(len(uniCR)):
        RepIssue.append(str(uniCR[m]) + '(x' + str(List_CR.count(uniCR[m])) + ')')
    return RepIssue


def checkLinkedIssue(issue):  # Check Linked Issues
    outwardlinked = ''
    if issue.fields.issuelinks is None:
        outwardlinked = "None"
    else:
        linkedissues = len(issue.fields.issuelinks)
        J = 0

        while (outwardlinked == '') and (J < linkedissues):
            try:
                if issue.fields.issuelinks[J].outwardIssue is None:
                    outwardlinked = 'None'
                else:
                    outwardlinked = issue.fields.issuelinks[J].outwardIssue.key
            except:
                pass
            J += 1
    return outwardlinked


def issueFinal(issue):
    status = getIssueStatus(issue)
    resolution = getIssueResolution(issue)
    if (status in ISSUE_CLOSED) and (resolution in ISSUE_RESOLVED):
        if ('QSTABILITY'in issue.key) or ('CNSSDEBUG' in issue.key) :
            #if status==""
            final = issue.fields.customfield_12830
            if final is None:
                final = checkLinkedIssue(issue)
                if final == 'None' or final == '':
                    final = issue.key
                else:
                    try:
                        final = issueFinal(jira.issue(final.replace(' ','')))
                    except:
                        pass
            final = final.upper()
            if final.find('CR') != -1:
                finalinter = final[final.rfind('CR'):]
                finalinter = finalinter.replace('/', '')
                finalinter =finalinter.strip()
                finalinter =finalinter[:8]
                if (finalinter.strip('CR')).isnumeric():
                    final =finalinter
                else:
                    final=final.lower()
            elif checkStr(final) != 'None':
                intrstate = checkStr(final)
                final1 = final[final.rfind(intrstate):]
                if final == issue.key:
                    final = issue.key
                else:
                    try:
                        final = issueFinal(jira.issue(final1.replace(' ','')))
                    except:
                        pass
            elif final.isnumeric():
                final= final.strip()
                final = 'CR' + final
            else:
                final = final
        else:
            final = issueDFinal(issue)
    else:
        final = issue.key
    return final


def checkStr(str):
    found = ''
    index = 0
    if any(x in str for x in Stability):
        while found == '':
            if Stability[index] in str:
                found = Stability[index]
            index += 1
    else:
        found = 'None'
    return found


def getparam():  # Getting Search Parameters from Command Line
    param = ['', '', '', '', '','','']
    startDate = 0
    endDate = 1
    buildID = 2
    Site = 3
    Component = 4
    Summary = 5
    Deptt = 6
    argno = len(sys.argv)
    for k in range(argno):
        J = sys.argv[k]
        J= J.upper()
        if '=' in J:
            if J[:J.index('=')] == 'STARTDATE':
                param[startDate] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'ENDDATE':
                param[endDate] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'BUILDID':
                param[buildID] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'SITE':
                param[Site] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'COMPONENT':
                param[Component] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'SUMMARY':
                param[Summary] = J[J.index('=') + 1:]
            elif J[:J.index('=')] == 'DEPTT':
                param[Deptt] = J[J.index('=') + 1:]
    return param


def jiraquery(param):
    global FileSummary
    Site = ''
    query = '(project in ( WCNSTABLE,CNSSDEBUG) '# QSTABILITY '
    if param[0] != '':
        query = query + ' and createdDate >= ' + param[0]
    if param[1] != '':
        query = query + ' and createdDate <= ' + param[1]
    if param[2] != '':
        query = query + ' and (cf[10933] ~ ' + '"' + param[2] + '*' + '"'+ ' or cf[26413] ~ ' + '"' + param[2] +'*' +'" )'
    if (param[3] != '') and (param[6]==''):
        if param[3] == 'QIPL':
            Site = '"08399" or cf[10221] ~ "04567"' +' OR reporter in (c_mmaury,c_awmoha) )'# '6186
        elif param[3] == 'SD':
            Site = '5411'
        elif param[3] == 'FF':
            Site = '6459'
        elif param[3] == 'CHINA':
            Site = '"8764 or 8765"'
        query = query + ' and ( cf[10221] ~ ' + Site
    if param[4] != '':
        query += ' and Component in ( ' + param[4] + ')'
    if param[5] != '':
        if param[5] == '1':
            FileSummary = True
    if (param[6] != '') and (param[3]==''):
        query += ' and (cf[10221] ~ "' +param[6] +'")'

    return query


def maxhitter(A):
    max2min = []
    result = ''
    for i in range(len(A)):
        if ('(' in A[i] ) or (')' in A[i] ):
            A[i]= A[i].replace('(','')
            A[i] = A[i].replace(')','')
    while len(A) > 0:
        d = defaultdict(int)
        for i in A:
            d[i] += 1
            result = max(d.iteritems(), key=lambda x: x[1])
        A = list(ifilterfalse((lambda x: re.search(str(result[0]), x)), A))
        max2min.append(str(result[0]) + '(x' + str(result[1]) + ')')
    return max2min


def rejectList(ListA, str):
    ListB = list(ifilterfalse((lambda x: re.search(str, x)), ListA))
    return ListB


def getbuildID(buildinfo):
    buildinfo=buildinfo[:buildinfo.find('\r')]
    buildinfo=buildinfo.replace('|','')
    buildinfo=buildinfo.replace('{','')
    buildinfo=buildinfo.replace('}','')
    buildinfo=buildinfo.replace('color','')
    buildinfo =buildinfo[buildinfo.find('\\'):]
    buildinfo =buildinfo[buildinfo.rindex('\\')+1:]
    return buildinfo

def getCNSDEBUGAPSS(buildinfo):
    buildinfo =buildinfo.upper()
    buildinfo =buildinfo[buildinfo.find('APPS'):]
    buildinfo =buildinfo[buildinfo.find('\\\\'):]
    buildinfo=buildinfo[2:buildinfo.find('\r')]
    apss = buildinfo
    if 'LNX.' in apss:
        apss =apss[apss.find('LNX.'):]
        if '\\' in apss:
           apss =apss[:apss.find('\\')+1]
    elif 'LA.B' in apss:
        apss =apss[apss.find('LA.B'):]
        if '\\' in apss:
           apss =apss[:apss.find('\\')+1]
    elif 'LA.' in apss:
        apss =apss[apss.find('LA.'):]
        if '\\' in apss:
           apss =apss[:apss.find('\\')+1]
    elif 'KK_' in apss:
        apss =apss[apss.find('KK_'):]
        if '\\' in apss:
           apss =apss[:apss.find('\\')+1]
    elif 'OXYGEN' in apss:
        oxy = apss.find('-OXYGEN')
        apss =apss[:apss.find('\\',oxy)]
        apss =apss[apss.rfind('\\')+1:]

    if 'OXYGEN' not in apss:
        apss =apss[:apss.find('-')]
    #print (apss)
    return  apss





def gethostname(namehost):
    namehost =namehost[namehost.find('Host Name'):]
    namehost =namehost[:namehost.find('\r')]
    namehost =namehost[namehost.find('|'):]
    namehost =namehost.replace('|','')
    return namehost

def getplName(Plname):
    Plname= Plname[:Plname.find('\r')]
    Plname =Plname.replace('{','')
    Plname=Plname.replace('}','')
    Plname =Plname.replace('color','')
    Plname =Plname.replace('blue','')
    Plname =Plname[:Plname.rindex(':')]
    Plname =Plname[Plname.rindex(':')+1:]
    Plname =Plname.replace('|','')
    if any (x in Plname for x in PLs):
        plid =Plname
    else:
        plid ='Engg Build'
    return plid

def getbuildIDCNstable(IDbuid):
    IDbuid = IDbuid[IDbuid.rindex('\\')+1:]
    return  IDbuid






def findPL(buildId):
    #print ("Finding PL number for build %s..." , buildId)

    pl = ""
    try:
        output = subprocess.check_output("FindBuild.exe " + buildId + " -lo", shell=True)
        #output = "ProductLine:     MSM8926.LA.2.0 OSVer:  HWPlatform: MSM8926"
        #print ("===================================================")
        #print (str(output))
        #print ("===================================================")
        m = re.search(r"ProductLine:\s+(.+)?\s+OSVer:", output, re.MULTILINE)  
        if m:
            pl = m.group(1)
            #print ("PL found: [%s]" , pl)
        else:
            print ("Error: Failed to find PL!")
    except Exception as err:
        print ("Exception in finding PL: " + str(err))
    return (pl)

def findPL_Meta_APSS_CNSS(buildId):
    #print ("Finding PL number for build %s..." , buildId)
    Image =''
    ImageAPPSPL=''
    ImageCNSSPL =''
    ImageBuild=''
    MetaPL =[]

    SP = ""
    try:
        output = subprocess.check_output("FindBuild.exe " + buildId + " -lo", shell=True)
        #output = "ProductLine:     MSM8926.LA.2.0 OSVer:  HWPlatform: MSM8926"
        #print ("===================================================")
        #print (str(output))
        #print ("===================================================")
        m = re.search(r"ProductLine:\s+(.+)?\s+OSVer:", output, re.MULTILINE)
        y=  re.search(r"MainMake:(.+)?(.+)\n", output, re.MULTILINE)

        if m:
            SP = m.group(1)

            if y:
                testpl = y.group(1)

                testPL =testpl.strip(' ')
                testPL =testPL.upper()
                testPL =testPL.split(' ')

                f = filter((lambda x: re.search(r':', x)), testPL)
                if len(f) >0 :
                    for each in f :
                        if ('APPS' in each) and ('TN.' not in each)  :
                            Image = each[:each.find(':')]
                            ImageBuild =each[each.find(':')+1:]
                            ImageAPPSPL = findPL(ImageBuild)

                        elif ((('CNS'in each )or ('WCN' in each) or ('WLAN' in each)) and ('ADDON' not in each)):
                            Image = each[:each.find(':')]
                            ImageBuild =each[each.find(':')+1:]
                            ImageCNSSPL = findPL(ImageBuild)

        else:
            print ("Error: Failed to find PL!")
    except Exception as err:
        print ("Exception in finding PL For Meta: " + str(err))
    return (SP,ImageAPPSPL,ImageCNSSPL)

class ProcessedTicket:
    def __init__(self,name=None,build =None,deviceid=None,mcn=None,status=None,resolution=None):
        self.name =name
        self.build =build
        self.deviceid =deviceid
        self.mcn =mcn
        self.status =status
        self.resolution =resolution

class BuildDetails:
    def __init__(self,name=None,metaPL=None, apps=None,CNSS=None, TZ=None,RPM=None):
        self.name = name
        self.metaPL = metaPL
        self.apps =apps
        self.CNSS =CNSS
        self.TZ =TZ
        self.RPM =RPM

user = "unagi"
pw = "Fishhead89"

jira = JIRA(options={'server': 'https://jira-stability.qualcomm.com/jira', 'verify': False},
                basic_auth=(user, pw))  # a username/password tuple   Creating Jira object to communicate to Jira Server

def main():

    global user
    global pw, Build_PL ,Build_PLAP , Build_PLCN
    global MAX_JIRA_ISSUES,FileSummary
    global JIRA_ISSUES_INTERVAL
    global jira ,  report , Resultfile , List_CR , Total_issues, ISS_FIX, prism, uniCR, PLNAME, apss, cnssImage, buildID
    station =''
    crash_location =''
    statusTicket =''
    resoTicket =''
    #ListImage =[]
    ListImage =['MPSS.JO.1.0', 'MPSS.TA.1.0', 'LA.BR.1', 'LNX.LA.3.7.1.1', 'LA.BR.1.2.3', 'APSS.WP_CH.1.0', 'LF.BR.1.2.3', 'TZ.BF.2.5', 'BOOT.BF.3.1', 'CNSS.PR.2.0.2', 'VP.MSM8909.1.0', 'CNSS.PR.2.2', 'MPSS.JO.1.0.c1', 'RPM.BF.2.1', 'LA.BR.1.2.3.c1', 'LNX.LA.3.7.1.1.c1', 'MPSS.JO.1.0.r3', 'CNSS.PR.3.0', 'LA.BR64.1.1.1', 'LA.BR.1.3.1', 'GLUE.MSM8909_WP.1.0', 'VP.MSM8909.0.1', 'CNSS.PR.1.4.2', 'BOOT.BF.3.0', 'BOOT.BF.3.1.1', 'LNX.LA.0.0', 'MPSS.JO.1.0.r1', 'LA.BR.1.2.1', 'LA.BR.1.1.2', 'WINSECAPP.BF.2.3', 'LA.BR64.1.1', 'RPM.BF.2.0', 'VP.MSM8909.0.0', 'LA.BR.1.2', 'MPSS.JO.1.0.r2', 'CNSS.PR.1.4.2.c8.1', 'CNSS.PR.1.4.2.c8.3', 'CNSS.PR.1.4.2.c8.2', 'CNSS.CHROM.1.0', 'CHROM.CNSS.1.0' ]
    buildmetasp ={}
    buildmetapl ={}


    if MAX_JIRA_ISSUES < JIRA_ISSUES_INTERVAL:
        JIRA_ISSUES_INTERVAL = MAX_JIRA_ISSUES

    '''jira = JIRA(options={'server': 'https://jira-stability.qualcomm.com/jira', 'verify': False},
                basic_auth=(user, pw))  # a username/password tuple   Creating Jira object to communicate to Jira Server
    '''
    print('Connected to Server')
    print('Starting issue search')
    print('issue search started')
    print('Start time', time.asctime(time.localtime(time.time())), sep=',')

    query = jiraquery(getparam())
    #query ='(project=WCNSTABLE  and createdDate >= 2014-12-04 and cf[10221] ~ "8399 or 4567" )  ORDER BY createdDate asc'
    query += ' )  ORDER BY createdDate asc'
    print(query)
    #print(FileSummary)

    ticket = getJiraIssues(query)
    print('search complete')
    print('Search complete Time', time.asctime(time.localtime(time.time())), sep=',')
    report ='WCNStatus-' + str(time.asctime(time.localtime(time.time())))
    report =report.replace(' ','-')
    report =report.replace(':','-')
    Report_Dir = 'CNS-PDT_Reports'
    if not os.path.exists(Report_Dir):
        os.makedirs(Report_Dir)
    report = Report_Dir +'\\' + report
    Resultfile = open(report+'.csv', mode='w')
    #for issue in ticket:
    #    listIssue.append(issue.key)
    #k = len(listIssue)
    Total_issues = len(ticket)
    #ListImage.append('LNX.LA.3.7.1.1')

    '''--------------------------------------------------------------------------------------------------------------------'''

    print('Stability Ticket','PL-ID', 'Build','CNSS Image','APPS Image', 'Summary','Device ID',
          'MCN #', 'Final Resolution','Host Name', 'Crash Location','Combination','Date Created','Status','Resolution', sep=',', file=Resultfile)
    print('Total Issues found: ', Total_issues)
    if Total_issues >0 :
        for j in range(Total_issues):
            if 'WCNSTABLE' in ticket[j].key :

                ISS_FIX = issueFinal(ticket[j])
                if  ticket[j].fields.description != None:
                    station =gethostname(ticket[j].fields.description)
                else:
                    station ='None'
                #print(cnssImage)
                List_CR.append(ISS_FIX)
                if ticket[j].fields.customfield_10935 != None:
                    crash_location = ticket[j].fields.customfield_10935
                    crash_location =crash_location.encode('ascii','ignore')
                else:
                    crash_location='None'
                if ticket[j].fields.customfield_10933 != None:
                    buildID =getbuildIDCNstable(ticket[j].fields.customfield_10933)
                else:
                    buildID ='None'

            elif 'CNSSDEBUG' in ticket[j].key :
                ISS_FIX = issueFinal(ticket[j])
                List_CR.append(ISS_FIX)
                crash_location = ticket[j].fields.customfield_26610
                crash_location =crash_location.encode('ascii','ignore')
                buildID = getbuildID(ticket[j].fields.customfield_26413)
                infoBuild = ticket[j].fields.customfield_26413
                if  ticket[j].fields.description != None:
                    station =gethostname(ticket[j].fields.description)
                    station = station.encode('ascii','ignore')
    #-------------------------------------------------------------------------------------------------------------------
            if buildID == 'None':
                PLNAME ='None'
                apss ='None'
                cnssImage = 'None'
            else:
                if buildmetasp.has_key(buildID):
                    PLNAME = buildmetasp[buildID]
                    apss = buildmetapl[buildID][:buildmetapl[buildID].find(',')]
                    cnssImage = buildmetapl[buildID][buildmetapl[buildID].find(',')+1 :]
                else:
                    (PLNAME,apss,cnssImage) = findPL_Meta_APSS_CNSS(buildID)
                    buildmetasp[buildID] = PLNAME
                    buildmetapl[buildID] = apss + ',' +cnssImage

    #-------------------------------------------------------------------------------------------------------------------
            statusTicket = ticket[j].fields.status
            resoTicket = ticket[j].fields.resolution
            ISS_FIX =ISS_FIX.encode('ascii','ignore')
            PLNAME =PLNAME.encode('ascii','ignore')
            cnssImage =cnssImage.encode('ascii','ignore')
            apss =apss.encode('ascii','ignore')
            BuildCombi = PLNAME + '+'+cnssImage +'+'+apss
            sr_no = ticket[j].fields.customfield_14929
            sr_no = sr_no.encode('ascii','ignore')
            mcn_no = ticket[j].fields.customfield_14930
            mcn_no = mcn_no.encode('ascii','ignore')

            issueText=ticket[j].fields.summary
            issueText=issueText.replace(',',':')
            issueText=issueText.replace('\r','')
            issueText=issueText.replace('\n','')
            issueText=issueText.replace('\t','')
            issueText=issueText.encode('ascii','ignore')


            print(ticket[j].key,PLNAME,buildID,cnssImage,apss,issueText, sr_no, mcn_no, ISS_FIX,
                  station,crash_location,BuildCombi,ticket[j].fields.created[:10],statusTicket,resoTicket, sep=',', file=Resultfile)

            print(j + 1, 'Issue(s) processing done', end='\r')
        print()

        Resultfile.close()
        print('csv generated ', time.asctime(time.localtime(time.time())))
        if FileSummary :
            print('Process Finish Time', time.asctime(time.localtime(time.time())), sep=',')
            uniCR = set(List_CR)
            uniCR = list(uniCR)
            uniCR.sort()
            onlyCRList = filter((lambda x: re.search(r'CR', x)), List_CR)
            sotedCR = maxhitter(onlyCRList)
            underAnalysis = filter((lambda x: re.search(r'-', x)), List_CR)
            sortedAnalysis = maxhitter(underAnalysis)

            #cRSunique=filter((lambda x: re.search(r'CR', x)),uniCR)

            print('Number of CR(s):', len(sotedCR))

            Reject = rejectList(List_CR, 'CR')
            Reject = rejectList(Reject, '-')
            issuesRejected = len(Reject)
            Reject = maxhitter(Reject)


            SummaryFile = open(report +'.txt', 'w')
            print('Report Generated At: ' + str(time.asctime(time.localtime(time.time()))), file=SummaryFile)
            print('Total Issue:' + str(Total_issues), file=SummaryFile)
            print('Unique Isuues:' + str(len(uniCR)), file=SummaryFile, end=':\n')
            print('Number of CR(s):', len(sotedCR), file=SummaryFile)

            for m in range(len(sotedCR)):
                if 'CR' in sotedCR[m]:
                    print(sotedCR[m], file=SummaryFile )
            print('Unique Issue(s) Under Analysis: (x' + str(len(sortedAnalysis)) + ')', file=SummaryFile)
            for m in range(len(sortedAnalysis)):
                if '-' in sortedAnalysis[m]:
                    print(sortedAnalysis[m], file=SummaryFile)
                    

            if len(sotedCR)>0 :
                print('Connecting to Prism')
                prism = Prism('http://prism:8000/ChangeRequestWebService.svc?wsdl', user, pw)
                print('Connected to Prism')
            print(file=SummaryFile)
            print('Issues Details:', file=SummaryFile)
            print(file=SummaryFile)
            for m in range(len(sotedCR)):
                if 'CR' in sotedCR[m]:
                    ChangeReq = sotedCR[m]
                    ChangeReq = ChangeReq[2:ChangeReq.index('(')]
                    #title = prism.getChangeRequestTitle(ChangeReq)
                    (st,crDate,a, b, c,title) = prism.getChangeRequestDetailsDateStatus(ChangeReq)
                    #(a1,b1,c1,d1,e1,f1,g1,h1)= prism.getChangeRequestDetailsPL(ChangeReq,ListImage)
                    #print ('CR'+ChangeReq,a1,b1,c1,str(d1)[:10],str(e1)[:10],f1,g1,h1,sep= ' , ')
                    crDate= str(crDate)[:10]
                    print(sotedCR[m],title, file=SummaryFile, sep=':')
                    title=title.encode('ascii','ignore')
                    #print('\t',st,crDate,'FA:',a,b,c,title,sep=',', file=SummaryFile)
                    print(m+1,':CR(s) Processed',end='\r')
                    print('\t','Status:',st,'DateCreated:',crDate, 'FA:', a, '->', b, '->', c, file=SummaryFile)
            print('Issue Under Analysis: (x' + str(len(sortedAnalysis)) + ')', file=SummaryFile)
            for m in range(len(sortedAnalysis)):
                if '-' in sortedAnalysis[m]:
                    print(sortedAnalysis[m], file=SummaryFile, end=':')
                    Summ = sortedAnalysis[m]
                    Summ = Summ[:Summ.index('(')]
                    try:
                        Summ = jira.issue(Summ.replace(' ',''))
                        print(Summ.fields.created[:10], Summ.fields.summary,sep=',', file=SummaryFile)
                    except:
                        print('')
                        pass
                #print(m,':')
            print('Rejected Issues: (x' + str(issuesRejected) + ')', file=SummaryFile)
            for m in Reject:
                print(m, file=SummaryFile)

            SummaryFile.close()
            print('Summary Generated', time.asctime(time.localtime(time.time())), sep=',')
    else:
        print('No Issue found , please check query ')
if __name__ == "__main__":
    main()
