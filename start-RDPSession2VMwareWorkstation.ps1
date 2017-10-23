#-- VMware workstation details
$vCenter= 'localhost'
$vCenterPort= 10443 #-- make sure VMware workstation has sharing enabled on port 10443

#-- Check if Royal TS is installed (using windows registry)
if (!(Test-Path "HKCR:")) {
    #-- open registry
    new-psdrive -name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null
}
    #-- check if there is a shell open command for royalTS
if (Test-Path -Path "HKCR:\code4ward.net.Royal TS\Shell\open") {
    $Royal_TS=Get-Item "HKCR:\code4ward.net.Royal TS\Shell\open\command\" | Get-ItemProperty -name '(Default)' | select -ExpandProperty '(default)'
    #-- filter the fileplath
    $Royal_TS=$Royal_TS.replace('" "','";"').split(";")[0].replace('"','')
}
#-- check if RoyalTS is installed
$Use_RoyalTS=(Test-Path $Royal_TS) #-- True if RoyalTS is found
#-- unmount registry
Remove-PSDrive HKCR -Confirm:$false | Out-Null

#-- load PowerCLI
get-module vmware* -ListAvailable | Import-Module
#-- Connect to vCenter service
Connect-VIServer -Server $vCenter -Port $vCenterPort -ErrorVariable Err1
if ($err1) {
    exit
}

#-- Select VM to connect to
if (get-vm) {
    if ($vm -eq $null) {
        #-- exit when no VM is selected
        Exit
    }

    #-- Make sure VM is powered On
    write-host "Checking if VM is powered ON"
    do {
        #-- Check powerstate of VM
        switch ($vm.PowerState) {
            "PoweredOn" {  }
            "PoweredOff" {
                #-- VM is Powered Off, first start VM
                start-vm -Name $vm
                #-- Wait loop with Timeout watchdog
                $TS_wait=get-date
                do {
                    sleep -Seconds 5
                    $TO=(get-date - $TS_wait).Minute -le 5 #-- [boolean] looped timedout
                } until ($vm.PoweredOn -or $TO )

                if ($TO) { 
                    write-host "VM didn't start, can't initiate a RDP session."
                    Exit
                }
            }
            Default {}   
        } 
    } until ($vm.Powerstate -eq "PoweredOn") 

    #-- Test if RDP port is accesible
    write-host "Checking if RDP port is accesible"
    $RDP_tst=Test-NetConnection -ComputerName $vm.ExtensionData.guest.IpAddress -CommonTCPPort RDP
    if ($RDP_tst.tcptestsucceeded){
        #-- start a RDP session to the VM... RoyalTS is prefered
        if ($Use_RoyalTS){
            Start-Process -FilePath $Royal_TS -ArgumentList ("/uri:"+ $vm.ExtensionData.guest.ipaddress+ " /using:adhoc")
        } else {
            #-- No royal TS found so use MSTSC
            Start-Process mstsc.exe -ArgumentList ("/v:"+$vm.ExtensionData.guest.ipaddress)
        }
    } else {
        write-host "Kan geen RDP sessie naar VM starten, Test antwoord was:"
        $rdp_tst
    }


    
}

Disconnect-VIServer -Confirm:$false -Server $global:DefaultVIServers