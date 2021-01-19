#! /bin/sh

scheme=${HILINK_PROTO:-'http'}
host=${HILINK_HOST:-'192.168.1.1'}
port=${HILINK_PORT:-'80'}
curl_options="-fsSH 'Host:Hi.link'"

# Get a cookie/session id
RESPONSE=`curl $curl_options -X GET $scheme://$host:$port/api/webserver/SesTokInfo`
COOKIE=`echo "$RESPONSE"| grep SessionID=| cut -b 10-147`
TOKEN=`echo "$RESPONSE"| grep TokInfo| cut -b 10-41`

case "$1" in
connect)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/dialup/dial" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" \
    -d"<request><Action>1</Action></request>" 
;;
disconnect)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/dialup/dial" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" \
    -d "<request><Action>1</Action></request>" 
;;
send_sms)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/sms/send-sms" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" \
    -d "<request><Index>-1</Index><Phones><Phone>$2</Phone></Phones><Sca>$sca</Sca><Content>$3</Content><Length>${#3}</Length><Reserved>1</Reserved><Date>$(date '+%Y-%m-%d %T')</Date></request>"
;;
get_sms)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/sms/sms-list" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" \
    -d "<request><PageIndex>1</PageIndex><ReadCount>${2:-1}</ReadCount><BoxType>1</BoxType><SortType>0</SortType><Ascending>0</Ascending><UnreadPreferred>1</UnreadPreferred></request>"
;;
sms_inbox)
    $0 get_sms 50
;;
sms_count)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/sms/sms-count" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" 
;;
traffic_statistics)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/monitoring/traffic-statistics" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" 
;;
check_notifications)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/monitoring/check-notifications" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" 
;;
status)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/monitoring/status" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN"     
;;
dialup_connection)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/dialup/connection" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" 
;;
device_information)
    curl $curl_options \
    -X GET "$scheme://$host:$port/api/device/information" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" 
;;

send_ussd)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/ussd/send" \
    -H "Cookie:$COOKIE" \
    -H "__RequestVerificationToken:$TOKEN" \
    -d "<Request><Content>$2</Content><CodeType>CodeType</CodeType></Request>";
;;
get_ussd)
    curl $curl_options \
    -X POST "$scheme://$host:$port/api/ussd/get" \
    -H "Cookie: $COOKIE" \
    -H "__RequestVerificationToken: $TOKEN" \
    -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
    -d "<request><content>$2</content><codeType>CodeType</codeType><timeout></timeout></request>";
;;
*)
cat >&2 << EOF
#######################
#    HILINK API TOOL  #
#######################
connect)
    Brings the modem online
disconnect)
    Brings the modem offline
send_sms)
    Send an sms message
    Usage: send_sms '\$mobile_number' '\$message'
get_sms)
    Poll the sms inbox (prints latest msg if count undefined)
    Usage: get_sms '\$count'
sms_inbox)
    Print the entire inbox
    Usage: get_inbox    
sms_count)
    Query number of SMS message
traffic_statistics)
    Report traffic statistics
check_notifications)
    Poll for new notification
status)
    Report device status
dialup_connection)
    Report dialup connection
device_information)
    Report device information
send_ussd)
    Send a USSD request
    Usage: send_ussd '\$ussd_number'
get_ussd)
    Query USSD response
    Usage: get_ussd '\$ussd_number'
EOF
;;
esac
