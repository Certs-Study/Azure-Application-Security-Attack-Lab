# Azure Application Security Attack Lab Scripts


## Overview

This repository contains a collection of PowerShell scripts designed to accompany the Azure Application Security Attack Lab by Altered Security. Each script demonstrates exploitation techniques against various Azure services and resources, allowing for a structured, educational approach to learning about Azure security vulnerabilities.

These scripts are designed for educational purposes only and should be used exclusively in controlled lab environments. 

## Lab Structure

The scripts follow the progression of learning objectives from the lab manual, gradually building up to complex attack chains that leverage multiple vulnerabilities.

### Prerequisites

- Windows environment with PowerShell
- Azure PowerShell modules installed
- Burp Suite Community/Professional
- Microsoft Azure Storage Explorer
- Access to the Lab environment
- Lab tools available in `C:\AzAppSec\Tools\`

## Scripts Description

### Discovery Phase

1. **LO-01: App Service Discovery** 
   - Uses MicroBurst to enumerate Azure App Services for Pharma Corp
   - Discovers resourcespharmacorp.azurewebsites.net and contactpharmacorp.azurewebsites.net

### Initial Access

2. **LO-04: LFI Vulnerability Exploitation**
   - Exploits Local File Inclusion vulnerability in the resources app
   - Extracts Azure AD Service Principal credentials from web.xml

3. **LO-09: File Upload Vulnerability Exploitation**
   - Demonstrates how to bypass file upload restrictions on the contact app
   - Uses Burp Suite to modify the filename with an escape character
   - Executes OS commands to view environment variables

4. **LO-10: RCE Vulnerability and Managed Identity Token**
   - Exploits RCE in the analytics application
   - Shows two techniques to bypass WAF and obtain access tokens
   - Provides instructions for using Pastebin or the contact app for hosting payloads

### Privilege Escalation

5. **LO-11: Service Principal Credential Abuse**
   - Uses credentials extracted from the resources app to authenticate
   - Checks for ownership rights on other enterprise apps
   - Adds new credentials to mailapp service principal

6. **LO-12: MS Graph API Permission Abuse**
   - Uses newly created mailapp credentials to authenticate
   - Checks Graph API permissions (User.Read.All and Mail.Read)
   - Lists users with email licenses and reads Marie Williams' emails
   - Discovers Azure Blob Storage URL

7. **LO-19: Key Vault Key and Secret Extraction**
   - Uses managed identity to get ARM and Key Vault access tokens
   - Extracts and decrypts Key Vault secrets
   - Retrieves the Function App master key

8. **LO-20: Function App Master Key Abuse**
   - Uses master key to read existing function source code
   - Creates a new function to request an access token
   - Uses the token to authenticate and enumerate resources

### Data Access

9. **LO-26: Storage Account Access via SAS Token**
   - Accesses blob container discovered in Marie's email
   - Extracts and decodes SAS token from mapped.xml
   - Provides instructions for using Azure Storage Explorer

10. **LO-27 & LO-28: Cosmos DB Access and Information Extraction**
    - Uses extracted connection string to access storage account
    - Retrieves PatientEntryApp.zip containing Cosmos DB credentials
    - Connects to Cosmos DB and extracts sensitive information
    - Finds potential credentials in document metadata

11. **LO-29: Access Final Cosmos DB**
    - Uses credentials found in previous steps to access final Cosmos DB
    - Provides instructions for Azure Portal access
    - Includes alternative PowerShell approach

## Usage Instructions

Each script includes detailed comments and instructions. Some scripts are designed to be run completely, while others provide step-by-step instructions for manual exploitation.

1. Start with LO-01 and proceed sequentially through the learning objectives
2. Read the script comments thoroughly before execution
3. Replace placeholder values with actual credentials you extract during the lab
4. Take note of the output as it will often be needed for subsequent steps

## Attack Chain Visualization

```
Discovery (LO-01)
    │
    ▼
LFI Exploit (LO-04) ────────► Service Principal Credentials
    │
    ▼
File Upload (LO-09) ────────► Web Shell Access
    │
    ▼
RCE Exploit (LO-10) ────────► Managed Identity Token
    │               │
    │               └─────────► Access to Key Vault (LO-19)
    ▼                           │
Credential Abuse (LO-11) ◄──────┘
    │
    ▼
Graph API Abuse (LO-12) ─────► Email Access
    │                          │
    │                          ▼
    │                    Storage Account URL (LO-26)
    ▼                          │
Function App Abuse (LO-20)     ▼
    │                    SAS Token Access
    ▼                          │
Cosmos DB Access (LO-27/28)◄───┘
    │
    ▼
Final Flag (LO-29)
```

## Security Measures and Recommendations

After completing the lab, consider the following security measures to protect Azure environments:

1. **App Service Security**
   - Implement proper input validation
   - Use Web Application Firewall (WAF)
   - Configure secure file handling

2. **Identity Security**
   - Follow the principle of least privilege
   - Monitor and rotate credentials
   - Use Azure AD Privileged Identity Management

3. **Storage Security**
   - Restrict anonymous access
   - Use short-lived SAS tokens
   - Implement private endpoints

4. **Function App Security**
   - Secure master keys
   - Implement IP restrictions
   - Monitor for unauthorized functions

5. **Cosmos DB Security**
   - Use private endpoints
   - Implement network security groups
   - Apply role-based access control

## Disclaimer

These scripts are provided for educational purposes only. The author and contributors are not responsible for misuse or for any damage that may result from the use of these scripts. Always obtain proper authorization before performing security testing.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
