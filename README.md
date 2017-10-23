# start-RDPSession2VMwareWorkstation #

Start an RDP session to a shared VM on a local VMware workstation

This script is released under the MIT license. See the License file for more details

## CHANGE LOG ##

|build|branch |  Change |
|---|---|---|
|0.0| Master| Initial release|

## How do I get set up ? ##

1. Download the repository to a folder.
1. Edit the parameters in top of the script. (vCenter and/or vCenterPort)
1. Run script.

## Dependencies ##

    - PowerShell 3.0
    - PowerCLI > 5.x

## How it works ##

When started, the script check the registry (HKCR) if the windows explorer shell has an 'open' item to open Royal TS files.  
If present, it deducts the location of Royal TS.
Then it connects to the local VMware Workstation service and asks the user to select the VM. After selecting the VM, it checks if the VM is started (if not, the VM will be started automaticly) and tests if the RDP port is accesible.  
If succesful, it will start a RDP session. Royal TS will be used preferably.
