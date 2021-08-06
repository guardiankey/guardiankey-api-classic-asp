<%
Response.LCID = 1033
%>
<!--#include file = "crypto.class.asp" -->
<!--#include file = "jsonObject.class.asp" -->
<%
class GK
  private organization_id
  private authgroup_id
  private key
  private iv
  private service
  private agentId
  private api_url

  public default function Init(gk_conf)
      organization_id = gk_conf.item("organization_id")
      authgroup_id    = gk_conf.item("authgroup_id")
      key             = gk_conf.item("key")
      iv              = gk_conf.item("iv")
      service         = gk_conf.item("service")
      agentId         = gk_conf.item("agentId")
      api_url         = "https://api.guardiankey.io/v2/checkaccess"
      set Init        = Me
  end function

  private function IP()
      Dim strIP :    set strIP = Request.ServerVariables("HTTP_X_FORWARDED_FOR") 
      If strIP = "" Then strIP = Request.ServerVariables("REMOTE_ADDR")
      IP = strIP
  end function

  function ConvertToUnixTimeStamp(input_datetime)
    dim d
    d = CDate(input_datetime) 
    ConvertToUnixTimeStamp = CStr(DateDiff("s", "01/01/1970 00:00:00", d)) 
  end function

  public function create_event(ByVal client_ip,ByVal user_agent,ByVal username,ByVal useremail,ByVal login_failed)
    set jsonEvent = new JSONobject
    jsonEvent.add "generatedTime",  ConvertToUnixTimeStamp(Now)
    jsonEvent.add "agentId",        agentId
    jsonEvent.add "organizationId", organization_id
    jsonEvent.add "authGroupId",    authgroup_id
    jsonEvent.add "service",        service
    jsonEvent.add "clientIP",       client_ip
    jsonEvent.add "clientReverse",  ""
    jsonEvent.add "userName",       username
    jsonEvent.add "authMethod",     ""
    jsonEvent.add "loginFailed",    login_failed
    jsonEvent.add "userAgent",      user_agent
    jsonEvent.add "psychometricTyped", ""
    jsonEvent.add "psychometricImage", ""
    jsonEvent.add "event_type",     "Authentication"
    jsonEvent.add "userEmail",      useremail
    ' response.write jsonEvent.serialize() ' DEBUG
    create_event = jsonEvent.serialize()
  end function

  public function check_access(ByVal username, ByVal useremail, ByVal login_failed)
    dim crypt : set crypt = new crypto
    dim client_ip :  client_ip  = IP()
    dim user_agent : set user_agent = Request.ServerVariables("HTTP_USER_AGENT")
    dim event_str :  event_str     = create_event(client_ip,user_agent,username,useremail,login_failed)
    dim hash      :  hash = crypt.hash(event_str & key &  iv,"SHA256","Hex")
    dim jsonMsgObj : set jsonMsgObj = new JSONobject
    jsonMsgObj.add "id",      authgroup_id
    jsonMsgObj.add "message", event_str
    jsonMsgObj.add "hash",    hash
    dim payload : payload = jsonMsgObj.serialize()
    set check_access = post_payload(payload)
  end function

  private function post_payload(ByVal payload)
    ' response.write payload ' DEBUG
    dim JSON : set JSON = New JSONobject
    dim oJSONoutput
    set ServerXmlHttp = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0")

    On Error Resume Next
    ServerXmlHttp.open "POST", api_url
    ServerXmlHttp.setRequestHeader "Content-Type", "application/json"
    ServerXmlHttp.setRequestHeader "Accept", "text/plain"
    ServerXmlHttp.setRequestHeader "Content-Length", len(payload)
    ServerXmlHttp.send payload

    If Err.Number <> 0 Then
      set post_payload = JSON.Parse("{""response"": ""ERROR""}")
      'response.write "Something went wrong!" ' DEBUG
      On Error GoTo 0
      Exit Function
    End If
    On Error GoTo 0

    if ServerXmlHttp.status = 200 then
        set oJSONoutput = JSON.Parse(ServerXmlHttp.responseText)
    else
        set oJSONoutput = JSON.Parse("{""response"": ""ERROR""}")
    end if
    set ServerXmlHttp = Nothing
    set post_payload = oJSONoutput
  end function
end class
%>