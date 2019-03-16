param(
    [object] $WebhookData
)

$input = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)

$customerName = $input.customerName

$connectionName = "AzureRunAsConnection"

$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 


$rg = "rg-WebApps"
$aspName = "ASP-Performance"

$templateURI = "https://raw.githubusercontent.com/whaakman/DeploymentAutomation/master/templates/webapp.json"

New-AzureRmResourceGroupDeployment `
         -name "CustomerDeployment" `
         -ResourceGroupName $rg `
         -TemplateUri $templateURI `
         -webAppName "APP-$customerName" `
         -appServicePlanName $aspName
