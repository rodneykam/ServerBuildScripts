pushd C:\hwebsource\initiate

./unattended.cmd
 
popd

sleep 10

pushd E:\mpi\project\initiate\scripts

./initiatesetup.ps1 $Prefix

sleep 2

./installpassive.bat

popd


