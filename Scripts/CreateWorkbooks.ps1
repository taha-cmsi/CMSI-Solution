# This is the parameter section, it will take the variables from the YAML file. The library that was pointed to in the variable group will be used in this script.
# The parameter section should match the ScriptArguments section in the YAML file otherwise it will cause a failing error.
param(
    [Parameter(Mandatory=$true)]$SubscriptionId, 
    [Parameter(Mandatory=$true)]$ResourceGroup,
    [Parameter(Mandatory=$true)]$WorkbooksFolder,
    [Parameter(Mandatory=$true)]$Workspace
)

#This series of commands finds the Workbook folder in GitHub, finds the JSON files for the Workbooks, and then establishes that these files are ARM templates.
Write-Host "Folder is: $($WorkbooksFolder)"
$armTemplateFiles = Get-ChildItem -Path $WorkbooksFolder -Filter *.json
Write-Host "Files are: " $armTemplateFiles
$workbookSourceId = "/subscriptions/$SubscriptionId/resourcegroups/$ResourceGroup/providers/microsoft.operationalinsights/workspaces/$Workspace"

#This command will attempt to deploy the resource to Azure Sentinel. If it fails it will generate a message associated with the error if one exists.
foreach ($armTemplate in $armTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $armTemplate -WorkbookSourceId $workbookSourceId 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Workbook deployment failed with message: $ErrorMessage" 
    }
}
