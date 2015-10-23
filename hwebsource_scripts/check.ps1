$dtd=.\parseDTD.ps1

$healthvaultdir = "E:\Buildout\hwebsource\dirstruct\healthvault\registercert.cmd"

$wincertdir = "E:\Buildout\hwebsource\dirstruct\healthvault\winhttpcertcfg.exe"

$hvsubject =$dtd.HealthVaultCertSubject 

clear-content $healthvaultdir

add-content -path $healthvaultdir -value "@SET WC_CERTNAME= $healthvaultdir"

add-content -path $healthvaultdir -value "@`"$wincertdir`" -g -a `"act`"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%"
add-content -path $healthvaultdir -value "@SET WC_CERTNAME="
add-content -path $healthvaultdir -value "@PAUSE"


