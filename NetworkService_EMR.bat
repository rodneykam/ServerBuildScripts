@SET WC_CERTNAME= emr-prod.relayhealth.com
@"E:\healthvault\winhttpcertcfg.exe" -g -a "Network Service"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%
@SET WC_CERTNAME=