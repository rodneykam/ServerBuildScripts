@SET WC_CERTNAME= emr-prod.relayhealth.com
@"E:\healthvault\winhttpcertcfg.exe" -g -a "SJPRWEB30SERV@RHF.AD"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%
@SET WC_CERTNAME=