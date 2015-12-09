$loc=Get-Location
$Appfabricpath=$loc.path+"\.."+"\AppFabric"

pushd $Appfabricpath
$Appfabricpath

./AppFabric.bat

popd
