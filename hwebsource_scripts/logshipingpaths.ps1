param ($CopyToServer,$logtype)	

[string] $ThisHost = hostname
if ($logtype -eq "IIS")
{
	$source_DestinationPaths= @(
			( "c:\inetpub\logs\LogFiles", "\\$CopyToServer\logs$\$ThisHost\IIS" ), 
			( "c:\inetpub\logs\AdvancedLogs", "\\$CopyToServer\logs$\$ThisHost\AdvancedIIS" ),
			( "e:\mpi\project\Initiate\passive\logs", "\\$CopyToServer\logs$\$ThisHost\Passivelogs" )
			)
}			
if ($logtype -eq "Relay")
{		
	$source_DestinationPaths= @(			
			( "e:\Relayhealth\logs\IMS", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\IMS" ), 
			( "e:\Relayhealth\logs\IMS_1", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\IMS_!" ), 
			( "e:\Relayhealth\logs\AppPoolRecycler", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\AppPoolRecycler" ), 
			( "e:\Relayhealth\logs\AutoArchiveOrdersLogs", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\AutoArchiveOrdersLogs" ), 
			( "e:\Relayhealth\logs\AutoReleaseToPhrLogs", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\AutoReleaseToPhrLogs" ), 
			( "e:\Relayhealth\logs\AutoResend", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\AutoResend" ), 
			( "e:\Relayhealth\logs\CoverageGroupImport", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\CoverageGroupImport" ), 
			( "e:\Relayhealth\logs\ChartingTemp", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ChartingTemp" ), 
			( "e:\Relayhealth\logs\CreditCardTransactionsDump", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\CreditCardTransactionsDump" ), 
			( "e:\Relayhealth\logs\DrugBenefitRxHistory", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\DrugBenefitRxHistory" ), 
			( "e:\Relayhealth\logs\ExpressIMS", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ExpressIMS" ), 
			( "e:\Relayhealth\logs\ExternalInterop", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ExternalInterop" ), 
			( "e:\Relayhealth\logs\FACSysTest", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\FACSysTest" ), 
			( "e:\Relayhealth\logs\FaxBridge", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\FaxBridge" ), 
			( "e:\Relayhealth\logs\Fax", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\Fax" ), 
			( "e:\Relayhealth\logs\Integration", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\Integration" ), 
			( "e:\Relayhealth\logs\InteropDrugBenefitEligAndMedHx", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\InteropDrugBenefitEligAndMedHx" ), 
			( "e:\Relayhealth\logs\InteropPrescriberUpdate", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\InteropPrescriberUpdate" ), 
			( "e:\Relayhealth\logs\InteropRxInterface", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\InteropRxInterface" ), 
			( "e:\Relayhealth\logs\InteropWebVisitEligibility ", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\InteropWebVisitEligibility " ), 
			( "e:\Relayhealth\logs\MessageSearch ", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\MessageSearch " ), 
			( "e:\Relayhealth\logs\MessageExchangeService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\MessageExchangeService" ), 
			( "e:\Relayhealth\logs\InboundActivityService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\InboundActivityService" ), 
			( "e:\Relayhealth\logs\SubscriberActivityService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\SubscriberActivityService" ), 
			( "e:\Relayhealth\logs\ExchangeInfrastructureService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ExchangeInfrastructureService" ), 
			( "e:\Relayhealth\logs\MessageTrackingService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\MessageTrackingService" ), 
			( "e:\Relayhealth\logs\Partners", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\Partners" ), 
			( "e:\Relayhealth\logs\PatientMergeQueueProcessor", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\PatientMergeQueueProcessor" ), 
			( "e:\Relayhealth\logs\ResolvePatientQueueProcessor", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ResolvePatientQueueProcessor" ), 
			( "e:\Relayhealth\logs\RelayEScriptRxHubSimulator", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\RelayEScriptRxHubSimulator" ), 
			( "e:\Relayhealth\logs\RelayEScriptSureScriptsSimulator", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\RelayEScriptSureScriptsSimulator" ), 
			( "e:\Relayhealth\logs\rTools", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\rTools" ), 
			( "e:\Relayhealth\logs\SSO", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\SSO" ), 
			( "e:\Relayhealth\logs\SureScriptsInterface", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\SureScriptsInterface" ), 
			( "e:\Relayhealth\logs\ImsToVortexRouterService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\ImsToVortexRouterService" ), 
			( "e:\Relayhealth\logs\WebServices", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\WebServices" ), 
			( "e:\Relayhealth\logs\LoggingPush", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\LoggingPush" ), 
			( "e:\Relayhealth\logs\MllpSimulator", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\MllpSimulator" ), 
			( "e:\Relayhealth\logs\Messaginglogs", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\Messaginglogs" ), 
			( "e:\Relayhealth\logs\Relay", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\Relay" ), 
			( "e:\Relayhealth\logs\AuditingService", "\\$CopyToServer\logs$\$ThisHost\Relaylogs\AuditingService" )
		)
}
return $source_DestinationPaths 

