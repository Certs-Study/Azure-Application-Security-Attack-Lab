# Learning Objective 1: Discover App Services
# This script uses MicroBurst to enumerate Azure subdomains for Pharma Corp
# Author: rfs85

# First, add additional permutations to the wordlist
$permutationsFile = "C:\AzAppsec\Tools\MicroBurst\Misc\permutations.txt"
Add-Content -Path $permutationsFile -Value "resources"
Add-Content -Path $permutationsFile -Value "contact"

# Import the MicroBurst module
. "C:\AzAppSec\Tools\MicroBurst\Misc\Invoke-EnumerateAzureSubDomains.ps1"

# Run the subdomain enumeration
Invoke-EnumerateAzureSubDomains -Base pharmacorp -Verbose

# Expected output will include:
# resourcespharmacorp.azurewebsites.net
# contactpharmacorp.azurewebsites.net
# and other discovered subdomains