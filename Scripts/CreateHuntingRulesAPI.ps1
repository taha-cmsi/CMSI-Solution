# This is the parameter section, it will take the variables from the YAML file. The library that was pointed to in the variable group will be used in this script.
# The parameter section should match the ScriptArguments section in the YAML file otherwise it will cause a failing error.
param(
    [Parameter(Mandatory=$true)]$Workspace,
    [Parameter(Mandatory=$true)]$RulesFile
)

#These commands add the AzSentinel module to the pipeline.
Install-Module AzSentinel -Scope CurrentUser -Force
Import-Module AzSentinel

#This is the name of the Azure DevOps locally generated artifact.
$artifactName = "HuntingFile"

#These commands build the full path for the hunting rule file.
$artifactPath = Join-Path $env:Pipeline_Workspace $artifactName 
$rulesFilePath = Join-Path $artifactPath $RulesFile

#This command gets all hunting rules from file and converts them from JSON to KQL.
$rules = Get-Content -Raw -Path $rulesFilePath | ConvertFrom-Json

#This command will attempt to deploy the resource to Azure Sentinel. If it fails it will generate a message associated with the error if one exists.
foreach ($rule in $rules.hunting) {
    Write-Host "Processing hunting rule: " -NoNewline 
    Write-Host "$($rule.displayName)" -ForegroundColor Green

    $existingRule = Get-AzSentinelHuntingRule -WorkspaceName $Workspace -RuleName $rule.displayName -ErrorAction SilentlyContinue
    
    if ($existingRule) {
        Write-Host "Hunting rule $($rule.displayName) already exists. Updating..."

        New-AzSentinelHuntingRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
    else {
        Write-Host "Hunting rule $($rule.displayName) doesn't exist. Creating..."

        New-AzSentinelHuntingRule -WorkspaceName $Workspace -DisplayName $rule.displayName -Query $rule.query -Description $rule.description -Tactics $rule.tactics -confirm:$false
    }
}
