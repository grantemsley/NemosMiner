if (!(IsLoaded(".\Include.ps1"))) {. .\Include.ps1;RegisterLoaded(".\Include.ps1")}

$Path = ".\Bin\CPU-Claymore\NsCpuCNMiner64.exe"
$Uri = "https://github.com/MultiPoolMiner/miner-binaries/releases/download/claymorecpu/Claymore.CryptoNote.CPU.Miner.v4.0.-.POOL.zip"

$Commands = [PSCustomObject]@{
    "cryptonightV7" = "" #CryptoNightV7
    #"cryptonight"  = "" #CryptoNight, ASIC 
}

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName

$Commands | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name | ForEach-Object {

    $Algorithm_Norm = Get-Algorithm $_

    [PSCustomObject]@{
        Type       = "CPU"
        Path       = $Path
        HashSHA256 = $HashSHA256
        Arguments  = "-r -1 -mport -$($Variables.CPUMinerAPITCPPort) -pow7 1 -o $($Pools.$Algorithm_Norm.Protocol)://$($Pools.$Algorithm_Norm.Host):$($Pools.$Algorithm_Norm.Port) -u $($Pools.$Algorithm_Norm.User) -p $($Pools.$Algorithm_Norm.Pass)$($Commands.$_)"
        HashRates = [PSCustomObject]@{(Get-Algorithm($_)) = $Stats."$($Name)_$(Get-Algorithm($_))_HashRate".Week}
        API        = "ClaymoreV2"
        Port       = $Variables.CPUMinerAPITCPPort
        Wrap       = $false
        URI        = $Uri
        User       = $Pools.(Get-Algorithm($_)).User
    }
} 
