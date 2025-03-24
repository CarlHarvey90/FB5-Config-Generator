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

    # Extract 'configurationFirebird' from the response to build databases.conf
    $databaseConfig = $response.configurationDatabase

    # Define output file path in the same directory as the script
    $outputFile = Join-Path -Path $PSScriptRoot -ChildPath "databases.conf"

    # Write the configuration to the file
    $databaseConfig | Out-File -FilePath $outputFile -Encoding UTF8

    Write-Host "Databases configuration saved to: $outputFile"

    # for quick debugging, prints response to console.
    $response | ConvertTo-Json -Depth 3  # Print JSON response
} catch {
    Write-Host "Error: $($_.Exception.Message)"
}
