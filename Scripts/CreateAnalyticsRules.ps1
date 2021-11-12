# This is the parameter section, it will take the variables from the YAML file. The library that was pointed to in the variable group will be used in this script.
# The parameter section should match the ScriptArguments section in the YAML file otherwise it will cause a failing error.
param(
    [Parameter(Mandatory=$true)]$SubscriptionId,
    [Parameter(Mandatory=$true)]$TenantId,
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$ClientId,
    [Parameter(Mandatory=$true)]$ClientSecret,
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$RulesFile
)

#These commands add the AzSentinel module to the pipeline.
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

#This is the name of the Azure DevOps locally generated artifact.
$artifactName = "RulesFile"

#These commands build the full path for the analytics rule file.
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

#This variable is used to point to the Resource URL to authentincate against.
$Resource = "https://management.azure.com/"

#Prepares Urls to be used for Sentinel API calls.
$IdUrl = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace"
$baseUri = "https://management.azure.com/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroup/providers/Microsoft.OperationalInsights/workspaces/$Workspace"

#Requests a token and uses it to help with identity verifications
$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
Write-Host "Print Token" -ForegroundColor Green
Write-Output $Token

#Headers add additional information to a token so that Azure will understand what the token will be used for.
$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
$Headers.Add("Content-Type", "application/json")

#Gets JSON content from artifacts that were published earlier in the YAML pipeline.
$rules = Get-Content -Raw -Path $rulesFilePath | ConvertFrom-Json

#This command will attempt to deploy the JSON file to Azure Sentinel. If it fails it will generate a message associated with the error if one exists.
try {
    Import-AzSentinelAlertRule -SubscriptionId $SubscriptionId -WorkspaceName $Workspace -SettingsFile $rulesFilePath
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Error "Rule import failed with message: $ErrorMessage" 
}
