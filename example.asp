<!--#include file = "gk.class.asp" -->
<%

' Something submited! Someone trying to access.
if request.form.count >0 then

  ' You can find this information at https://panel.guardiankey.io , settings->authgroups-> edit your authgroup -> tab deploy
  dim gk_conf : set gk_conf=Server.CreateObject("Scripting.Dictionary")
  gk_conf.Add "organization_id",""
  gk_conf.Add "authgroup_id",   ""
  gk_conf.Add "key",            ""
  gk_conf.Add "iv",             ""

  ' More information. May keep as is
  gk_conf.Add "service",        "myService"
  gk_conf.Add "agentId",        "myServer"

  set GKobj = new GK.Init(gk_conf)
  dim GKret

  if request.form("username") = "admin@mydomain.com" and request.form("password") = "pass" then
  ' User matched. Let's check with GuardianKey
    set GKret = GKobj.check_access(request.form("username"),request.form("username"),"0")
    if GKret.Value("response") = "BLOCK" then
        response.write "Attempt blocked by GuardianKey"
    else
        response.write "Welcome home!"
    end if
  else
    ' Last parameter is "1" in this case, ie, failed login
    set GKret = GKobj.check_access(request.form("username"),request.form("username"),"1")
    response.write "Invalid credentials"
  end if
  'response.write GKret.serialize() 'DEBUG ONLY
end if

%>
<%
if request.form.count = 0 then
%>
<html>
<head><title>Example page</title></head>
<form method="POST">
Username (admin@mydomain.com):<input type="text" name="username"><br />
Password (pass):<input type="password" name="password"><br />
<input type="submit" value="Access">
</form>
</html>
<%
end if
%>