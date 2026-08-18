<%@ Language=VBScript %>
<%
Option Explicit

Dim clipsEngine, resultString
Dim userAge

userAge = Request.QueryString("age")

If userAge <> "" Then
    ' Instantiate CLIPS COM ActiveX Wrapper
    Set clipsEngine = Server.CreateObject("CLIPS.Engine")
    
    ' Load rules and inject request facts
    clipsEngine.Load(Server.MapPath("insurance_rules.clp"))
    clipsEngine.Reset()
    clipsEngine.Assert("(applicant (age " & CInt(userAge) & "))")
    
    ' Run inference engine
    clipsEngine.Run()
    
    ' Retrieve output facts/results from memory
    resultString = clipsEngine.Eval("(find-fact ((?f risk-tier)) TRUE)")
    
    Set clipsEngine = Nothing
End If
%>
<!DOCTYPE html>
<html>
<body>
    <h2>Risk Assessment Result</h2>
    <p>Evaluated Tier: <%= resultString %></p>
</body>
</html>
