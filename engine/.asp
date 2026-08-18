<%
Dim engine, rulesFired, evalOutput
Set engine = Server.CreateObject("ClipsCom.Engine")

If engine.Load(Server.MapPath("rules.clp")) Then
    engine.Reset
    engine.Assert "(user-status (type premium) (score 85))"
    
    rulesFired = engine.Run()
    evalOutput = engine.Eval("(find-fact ((?f discount)) TRUE)")
    
    Response.Write "Fired Rules: " & rulesFired & "<br>"
    Response.Write "Result: " & evalOutput
End If

Set engine = Nothing
%>
