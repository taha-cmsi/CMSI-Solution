param(
    [Parameter(Mandatory=$true)]$resourceGroup,
    [Parameter(Mandatory=$true)]$LogicAppsFolder
)

Write-Host "Folder is: $($LogicAppsFolder)"

$armTemplateFiles = Get-ChildItem -Path $LogicAppsFolder -Filter *.json

Write-Host "Files are: " $armTemplateFiles

foreach ($armTemplate in $armTemplateFiles) {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $resourceGroup -TemplateFile $armTemplate 
    }
    catch {
        $ErrorMessage = $_.Exception.Message
        Write-Error "Logic App deployment failed with message: $ErrorMessage" 
    }
}