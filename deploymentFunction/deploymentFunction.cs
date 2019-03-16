using System.IO;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Text;
using Microsoft.Extensions.Configuration;

namespace deploymentFunction
{

    public static class Extensions
    {
        public static StringContent AsJson(this object o)
         => new StringContent(JsonConvert.SerializeObject(o), Encoding.UTF8, "application/json");
    }
    public static class DeploymentFunction
    {
        private static HttpClient httpClient = new HttpClient();

        [FunctionName("deploymentFunction")]

        //Set AuthorizationLevel to Anonymous for Azure AD Authentication
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log, ExecutionContext context)
        {
            log.LogInformation("Trigger Processed a request");

            // Access to App Settings
            var config = new ConfigurationBuilder()
            .SetBasePath(context.FunctionAppDirectory)
            .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables()
            .Build();

            // Get input
      
            string customername = req.Query["customername"];
            string customertype = req.Query["customertype"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            customername = customername ?? data?.customername;
            customertype = customertype ?? data?.customertype;

            // Check if customername is empty
            if (customername == null)
            {
               return new BadRequestObjectResult("Please pass the customer name");
            }

            string performancetype = customertype;

            // If no customertype is parsed, use standard performance tier as default
            string BaseUri = config["automationURIStandard"];

            switch (performancetype)
            {
                case "standard":
                    BaseUri = config["automationURIStandard"];
                    break;
                case "performance":
                    BaseUri = config["automationURIPerformance"];
                    break;
            }
            
            // Content webhook body
            var automationContent = new
            {
                customerName = customername
            };
        
            //Post to webhook
            var response = await httpClient.PostAsync(BaseUri, automationContent.AsJson());
            var contents = await response.Content.ReadAsStringAsync();

            return (ActionResult)new OkObjectResult(contents);
        }
    }   
}
