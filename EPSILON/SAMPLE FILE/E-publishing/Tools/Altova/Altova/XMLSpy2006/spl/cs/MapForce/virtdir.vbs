' create virtual directory on IIS
' run this once before opening the project in Visual Studio

Option Explicit

Dim sName, sPath, sServer

' name and path of virtual dir
sName = "[=$application.WSDLPort.AddressPath]"
sPath = "[write $outputpath & "\\" & $application.Name]"
sServer = "[=$application.WSDLPort.AddressServerAndPort]"

Dim oIIS, oDir
Set oIIS = GetObject("IIS://" & sServer & "/W3SVC/1/Root")
On Error Resume Next
Set oDir = oIIS.GetObject("IISWebVirtualDir", sName)
If Err.Number <> 0 Then Set oDir = oIIS.Create("IISWebVirtualDir", sName)
Err.Clear
oDir.AccessScript = True
oDir.Path = sPath
oDir.SetInfo

' create web application
oDir.AppCreate True
oDir.SetInfo

Set oDir = Nothing
Set oIIS = Nothing
