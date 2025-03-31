# API URL
$baseUrl = "https://cc.ib-aid.com"
$endpoint = "/rest/clc/calculation-params"
$apiUrl = $baseUrl + $endpoint
$cores =  2 #(Get-CimInstance Win32_Processor).NumberOfCores
$ram = 20 #[math]::Ceiling((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB)
$countUsers = 20

# JSON body
$jsonBody = @{
    mailLogin = "charvey@eureka.ie"
    passApi = "DhX1ge1754284773"
    serverVersion = "fb5"
    serverArchitecture = "SuperServer"
    cores = $cores
    countUsers = $countUsers
    sizeDb = 5
    pageSize = 16384
    ram = $ram
    nameMainDb = "mainBD"
    pathToMainDb = "c:/test/test.fdb"
    osType = "Universal"
    hwType = "Universal"
} | ConvertTo-Json -Depth 2  # Convert the hashtable to JSON

# POST request
try {
    $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $jsonBody -ContentType "application/json"

    Write-Host "Status: Success"

    # Extract 'configurationFirebird' from the response to build firebird.conf
    $firebirdConfig = $response.configurationFirebird

    # Define output file path in the same directory as the script
    $outputFile = Join-Path -Path $PSScriptRoot -ChildPath "firebird.conf"

    # Write the configuration to the file
    $firebirdConfig | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host "Firebird configuration saved to: $outputFile"
    
    #==========================================================================
    ## Write the databases.conf - removed 31/03/2025
    #==========================================================================
    ## Extract 'configurationFirebird' from the response to build databases.conf
    # $databaseConfig = $response.configurationDatabase

    ## Define output file path in the same directory as the script
    # $outputFile = Join-Path -Path $PSScriptRoot -ChildPath "databases.conf"

    ## Write the configuration to the file
    # $databaseConfig | Out-File -FilePath $outputFile -Encoding UTF8

    # Write-Host "Databases configuration saved to: $outputFile"
    #==========================================================================
    
    # for quick debugging, prints response to console.
    $response | ConvertTo-Json -Depth 3  # Print JSON response
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}

# Define the file path
$filePath = $outputFile

# Read all lines from the file
$content = Get-Content $filePath

# Remove specific lines based on keywords (case-sensitive)
$content = $content | Where-Object { 
    $_ -notmatch "#Configuration for Firebird 5" -and
    $_ -notmatch "#DefaultDbCachePages" -and
    $_ -notmatch "#set DataTypeCompatibility" -and
    $_ -notmatch "#DataTypeCompatibility" -and
    $_ -notmatch "#WireCryptPlugin" -and
    $_ -notmatch "#WireCompression" -and
    $_ -notmatch "#RemoteAuxPort" -and
    $_ -notmatch "#to check" -and
    $_ -notmatch "#authentication plugin setup" -and
    $_ -notmatch "#Recommendation" -and
    $_ -notmatch "#MaxIdentifierByteLength" -and
    $_ -notmatch "#MaxIdentifierCharLength" -and
    $_ -notmatch "#DefaultTimeZone" -and
    $_ -notmatch "#SnapshotsMemSize" -and
    $_ -notmatch "#TipCacheBlockSize"
}

# Remove empty lines (trim whitespace and filter out blank entries)
$content = $content | Where-Object { $_.Trim() -ne "" }

# Write the filtered content back to the file
$content | Set-Content $filePath

Write-Host "firebird.conf has been cleaned successfully!"

