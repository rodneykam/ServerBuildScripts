#Restart-Service -DisplayName 'RelayHealth ImsToVortexRouterService'
SC.exe STOP 'ImsToVortexRouterService'
sleep 5
SC.exe START 'ImsToVortexRouterService'
