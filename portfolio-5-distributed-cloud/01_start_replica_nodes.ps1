# Starts the three local mongod processes used by the TransMove replica-set lab.
# Existing MongoDB service on port 27017 is not modified.

$ErrorActionPreference = 'Stop'

$MongoD = 'C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe'
$Base = Join-Path $env:USERPROFILE 'mongodb-replica-lab'

if (-not (Test-Path -LiteralPath $MongoD)) {
    throw "MongoDB server executable was not found at: $MongoD"
}

$Nodes = @(
    @{ Name = 'node1'; Port = 27018 },
    @{ Name = 'node2'; Port = 27019 },
    @{ Name = 'node3'; Port = 27020 }
)

foreach ($Node in $Nodes) {
    $DataPath = Join-Path $Base $Node.Name
    $LogPath = Join-Path $DataPath 'mongod.log'
    New-Item -ItemType Directory -Force -Path $DataPath | Out-Null

    $ExistingListener = Get-NetTCPConnection -State Listen -LocalPort $Node.Port -ErrorAction SilentlyContinue
    if ($ExistingListener) {
        Write-Host "$($Node.Name) is already listening on port $($Node.Port). Skipping."
        continue
    }

    $MongoArgs = "--replSet rsTransMove --port $($Node.Port) --dbpath `"$DataPath`" --bind_ip 127.0.0.1 --logpath `"$LogPath`" --logappend"
    $Process = Start-Process -FilePath $MongoD -ArgumentList $MongoArgs -WindowStyle Hidden -PassThru
    Write-Host "$($Node.Name) launch requested. PID: $($Process.Id). Port: $($Node.Port)."
}

Start-Sleep -Seconds 3

Write-Host "`nReplica-set listener check:"
Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
    Where-Object { $_.LocalPort -in 27018, 27019, 27020 } |
    Sort-Object LocalPort |
    Select-Object LocalAddress, LocalPort, State
