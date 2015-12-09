$ACL = new-object System.Security.AccessControl.DirectorySecurity
$AccessRule = new-object System.Security.AccessControl.FileSystemAuditRule("everyone","FullControl","ContainerInherit,ObjectInherit", "None","Failure")
$ACL.SetAuditRule($AccessRule)
$ACL | Set-Acl "e:\RelayHealth\Resource"