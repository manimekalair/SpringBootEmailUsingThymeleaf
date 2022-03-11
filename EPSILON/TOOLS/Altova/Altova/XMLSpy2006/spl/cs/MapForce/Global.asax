[if $CreateVS2003Project
]<%@ Application Codebehind="Global.asax.cs" Inherits="[=$application.Name].Global" %>
[endif
if $CreateVS2005Project
]<%@ Application Codebehind="[=$application.Name].Global" Language="C#" %>
[endif]