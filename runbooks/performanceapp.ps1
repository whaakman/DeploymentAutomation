param(
    [object] $WebhookData
)

$input = $WebhookBody | ConvertFrom-Json


write-output $input

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

#change to templateURI
$templateFile = "C:\Users\whaak\OneDrive\Documenten\Code\Onboarding\templates\webapp.json"

New-AzResourceGroupDeployment `
         -name "CustomerDeployment" `
         -ResourceGroupName $rg `
         -TemplateFile $templateFile `
         -webAppName "APP-$customerName" `
         -appServicePlanName $aspName
