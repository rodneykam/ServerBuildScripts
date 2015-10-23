.\audit.ps1
.\wintertree.ps1

# ************************
# Create Hidden Shares  
# Sets the share permission to "Everyone" having "Full Control" of the share.
# It does not modify the file level/NTFS permissions on the folders.

# Create InteropShuntedEmails share **********************************
$ShareName = "InteropShuntedEmails$"
$FolderPath = "E:\RelayHealth\InteropShuntedEmails"
.\hiddenshares.ps1 -ShareName $ShareName -FolderPath $FolderPath 
# *********************************************************************

# Create ShuntedFaxes hidden share **********************************
$ShareName = "ShuntedFaxes$"
$FolderPath = "E:\RelayHealth\ShuntedFaxes"
.\hiddenshares.ps1 -ShareName $ShareName -FolderPath $FolderPath
# *********************************************************************

# Create ShuntedEmails hidden share  **********************************
$ShareName = "ShuntedEmails$"
$FolderPath = "E:\RelayHealth\ShuntedEmails"
.\hiddenshares.ps1 -ShareName $ShareName -FolderPath $FolderPath 
# *********************************************************************

# Create Logs hidden share  ******************************************
$ShareName = "Logs$"
$FolderPath = "E:\RelayHealth\Logs"
.\hiddenshares.ps1 -ShareName $ShareName -FolderPath $FolderPath 
# *********************************************************************