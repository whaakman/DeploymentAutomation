param(
    [object] $WebhookData
)

$input = $WebhookBody | ConvertFrom-Json

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
$aspName = "ASP-Standard"

$templateURI = "https://raw.githubusercontent.com/whaakman/DeploymentAutomation/master/templates/webapp.json"

New-AzResourceGroupDeployment `
         -name "CustomerDeployment" `
         -ResourceGroupName $rg `
         -TemplateParameterUri $templateURI `
         -webAppName "APP-$customerName" `
         -appServicePlanName $aspName
