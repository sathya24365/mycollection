# This script shows how to connect to a JIRA instance with a
# username and password over HTTP BASIC authentication.


from __future__ import print_function
from jira.client import *
from prism_report import *
from collections import defaultdict
from itertools import *
import unicodedata
import time
import sys
import shutil


FIELDS_CO = 'summary,status,resolution,reporter,issuelinks,description'  # COMMON JIRA FIELDS

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
FileSummary = False
#-------------------------------------------------------------------------------------------------------------------------------------------#


PROJECT = ''
BUILDID = ''

ISSUE_CLOSED = ["Closed", "Transferred"]
ISSUE_RESOLVED = ["Fixed", "Won't Fix", "Duplicate", "Complete", "Done"]
Final_RESO = ["FIXED", "WON'T FIX",  "COMPLETE", "DONE",'INVALID','WITHDRAWN']

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
                            final = issueDFinal(jira.issue(final))
                        except:
                            pass
                elif final.isnumeric():
                    final =final.strip()
                    final = 'CR' + final
            else:
                final = checkLinkedIssue(issue)
                if final != '':
                    try:
                        final = issueDFinal(jira.issue(final))
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
    StatusFinal ='CLOSED'
    ResolFinal ='FIXED'
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
                        final = issueFinal(jira.issue(final))
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
                        final = issueFinal(jira.issue(final1))
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

    if checkStr(final) != 'None':
        strfound = checkStr(final)
        final =final[final.find(strfound):]
        ticketLocal = jira.issue(final)
        StatusFinal = getIssueStatus(ticketLocal)
        ResolFinal = getIssueResolution(ticketLocal)
        ResolFinal =ResolFinal.upper()
        StatusFinal =StatusFinal.upper()
    return (final,StatusFinal,ResolFinal)


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
    param = ['', '', '', '', '','']
    startDate = 0
    endDate = 1
    buildID = 2
    Site = 3
    Component = 4
    Summary = 5
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
    if param[3] != '':
        if param[3] == 'QIPL':
            Site = '"8399" or  cf[10221] ~ "4567"' +' OR reporter in (c_mmaury,c_awmoha) )'# '6186
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

    return query


def FolderSpace(path):
    #print ("Finding PL number for build %s..." , buildId)
    import subprocess
    DiskSpace=''
    try:
        output = subprocess.check_output('dir /s /a ' + path + ' | find "(s)"', shell=True)
        m = output.splitlines()
        DiskSpace = m[len(m)-2]
        DiskSpace = DiskSpace[DiskSpace.find(')')+1:DiskSpace.find('bytes')]
        DiskSpace =DiskSpace.replace(',','')
        DiskSpace =DiskSpace.strip()
        DiskSpace =int(DiskSpace)
    except Exception as err:
        print ("Exception in finding Path: " + str(err))
    return (DiskSpace)



user = "unagi"
pw = "Fishhead89"

jira = JIRA(options={'server': 'https://jira-stability.qualcomm.com/jira', 'verify': False},
                basic_auth=(user, pw))  # a username/password tuple   Creating Jira object to communicate to Jira Server

def main():

    global user
    global pw
    global MAX_JIRA_ISSUES,FileSummary
    global JIRA_ISSUES_INTERVAL
    global jira ,  report , Resultfile , List_CR , Total_issues, ISS_FIX, prism, uniCR, pathTrue
    global Final_RESO ,ISS_Res


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
    report ='DumpStatus-' + str(time.asctime(time.localtime(time.time())))
    report =report.replace(' ','-')
    report =report.replace(':','-')
    Report_Dir = 'CNS-Dump_Reports'
    if not os.path.exists(Report_Dir):
        os.makedirs(Report_Dir)
    report = Report_Dir +'\\' + report
    Resultfile = open(report+'.csv', mode='w')

    Total_issues = len(ticket)

    '''--------------------------------------------------------------------------------------------------------------------'''

    #print('Stability Ticket','PL-ID', 'Build','CNSS Image','APPS Image', 'Summary','Device ID', 'MCN #', 'Final Resolution','Host Name', 'Crash Location','Combination', sep=',', file=Resultfile)
    print('WCN-Ticket','Crash-Location', 'Path-Exists','Final', 'Status','Resolution','SpacceBlocked', sep=',', file=Resultfile)
    print('Total Issues found: ', Total_issues)
    SpaceReleased = 0
    TotalSpaceblocked =0
    if Total_issues >0 :
        for j in range(Total_issues):
            if 'WCNSTABLE' in ticket[j].key :
                crash_location = ticket[j].fields.customfield_10935
            elif 'CNSSDEBUG' in ticket[j].key  :
                crash_location = ticket[j].fields.customfield_26610
            #SizeFolder = os.path.ge
            if 'rover' in crash_location :
                crash_location =crash_location.replace('rover','hope')
            pathTrue =False
            SpacceBlocked =0
            crash_location =crash_location.encode('ascii','ignore')
            try:
                if os.path.exists(crash_location):
                    pathTrue =True
                    (ISS_FIX,ISS_status,ISS_Res) = issueFinal(ticket[j])
                    if ('CR' in ISS_FIX) or ('INVALID' in ISS_FIX) or ('CLOSED' in ISS_status) or (ISS_Res in Final_RESO) or ('DROIDBUG' in ISS_FIX) :
                        SpaceReleased= SpaceReleased + FolderSpace(crash_location)
                        shutil.rmtree(crash_location)
                        SpacceBlocked=0
                    else:
                        SpacceBlocked = FolderSpace(crash_location)
                        TotalSpaceblocked =TotalSpaceblocked + SpacceBlocked
                else:
                    ISS_FIX='None'
                    ISS_status='None'
                    ISS_Res ='None'
            except:
                pass


            print(j + 1, 'Issue(s) processing done', end='\r')
            print(ticket[j].key,crash_location, pathTrue,ISS_FIX, ISS_status,ISS_Res, SpacceBlocked, sep=',', file=Resultfile)
        print()
        print('Disk Space Recoverd: ',int(SpaceReleased/(1024*1024*1024)), 'GB',';','Space Blocked: ',int(TotalSpaceblocked/(1024*1024)),' MB' )

    else:
        print('No Issue found , please check query ')
    Resultfile.close()
if __name__ == "__main__":
    main()
