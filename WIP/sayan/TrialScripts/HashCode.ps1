$shares = @{
"InteropShuntedEmails$" = "E:\RelayHealth\InteropShuntedEmails";
"ShuntedFaxes$" = "E:\RelayHealth\ShuntedFaxes";
"ShuntedEmails$" = "E:\RelayHealth\ShuntedEmails";
"Logs$" = "E:\RelayHealth\Logs"
}

foreach ($share in $shares) {Write-Host "$share"}