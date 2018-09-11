# Hard code this for now
$statuskey = "1BLXARB3GbKyEg8NTY56me5VXFsX2cixFB"


$Running = $Variables.ActiveMinerPrograms | Where-Object {$_.Status -eq "Running"} 

# Find the associated miner object and add it
$Running | Foreach-Object {
    $activeminer = $_;
    $miner = $Variables.Miners | Where-Object {$_.Arguments -eq $activeminer.Arguments}
    $_ | Add-Member -Force @{'MinerData' = $miner}
}

# Calculate the estimated profit for this particular machine - may be nowhere near the real earnings, but gives an idea of which machines are profiting the most.
$profit = ($Running.MinerData.Profit | Measure-Object -Sum).Sum | ConvertTo-Json

$minerreport = ConvertTo-Json @(
    $Running | Foreach-Object {
        $m = $_;
        [pscustomobject]@{
            Name = $m.Name
            Path = Resolve-Path -Relative $m.Path
            Type = @($m.Type)
            Active = "{0:dd} Days {0:hh} Hours {0:mm} Minutes" -f $m.Active
            Algorithm = @($m.Algorithms)
            Pool = @($m.minerdata.pools.psobject.properties.value.name)
            CurrentSpeed = @($m.HashRate)
            EstimatedSpeed = @($m.MinerData.HashRates.PSObject.Properties.Value)
            'BTC/day' = $m.MinerData.Profit
        }
    }
)

$Variables | Export-CliXml -Depth 12 -Path variables.xml
$Config | Export-CliXml -Depth 12 -Path config.xml
$minerreport | Export-CliXml -Depth 3 -Path minerreport.xml

try {
    $Response = Invoke-RestMethod -Uri "https://multipoolminer.io/monitor/miner.php" -Method Post -Body @{address = $statuskey; workername = $Config.WorkerName; miners = $minerreport; profit = $profit} -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop

    if ($Response -eq "success") {
        Update-Status("Miner Status ($MinerStatusURL): $Response")
    }
    else {
        Update-Status("Miner Status ($MinerStatusURL): $Response")
    }
}
catch {
    Update-Status("Miner Status ($MinerStatusURL) has failed. ")
}

