if (!(IsLoaded(".\Include.ps1"))) {. .\Include.ps1; RegisterLoaded(".\Include.ps1")}
 
$Path = ".\Bin\NVIDIA-Bminer1531\bminer.exe"
$Uri = "https://www.bminercontent.com/releases/bminer-lite-v15.3.1-8887ee1-amd64.zip"
$Commands = [PSCustomObject]@{
    "equihashBTG" = " -uri zhash://" #EquihashBTG(miniZ faster)
    "equihash" = " -uri stratum://" #Equihash(Asic)
    "equihash144" = " -pers auto -uri equihash1445://" #Equihash144(miniZ faster)
    "zhash" = " -pers auto -uri equihash1445://" #Zhash(miniZ faster)
    "ethash" = " -uri ethstratum://" #Ethash (Phoenix faster)
   #"aeternity" = " -uri aeternity://" #aeternity(testing)
    "beam" = " -uri beam://" #beam(fastest)
    "grincuckaroo29" = " -uri cuckaroo29://" #grincuckaroo29 
    #"grincuckatoo31" = " -uri cuckatoo31://" #grincuckatoo31
    
}
$Port = $Variables.NVIDIAMinerAPITCPPort
$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {
    $Algo = Get-Algorithm($_)
    $Pass = If ($Pools.($Algo).Pass -like "*,*") {$Pools.($Algo).Pass.ToString().replace(',','%2C')} else {$Pools.($Algo).Pass}
    [PSCustomObject]@{
        Type      = "NVIDIA"
        Path      = $Path
        Arguments = "$($Commands.$_)$($Pools.($Algo).User):$($Pass)@$($Pools.($Algo).Host):$($Pools.($Algo).Port) -max-temperature 94 -nofee -devices $($Config.SelGPUCC) -api 127.0.0.1:$Port"
        HashRates = [PSCustomObject]@{($Algo) = $Stats."$($Name)_$($Algo)_HashRate".Day}
        API       = "bminer"
        Port      = $Port
        Wrap      = $false
        URI       = $Uri    
        User = $Pools.($Algo).User
        Host = $Pools.($Algo).Host
        Coin = $Pools.($Algo).Coin
    }
}
