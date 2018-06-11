using System;
using System.IO;
using Microsoft.ConfigurationManagement.Messaging.Framework;
using Microsoft.ConfigurationManagement.Messaging.Messages;
using Microsoft.ConfigurationManagement.Messaging.Sender.Http;
using System.Diagnostics;

namespace SimulateClient

{

    class Program

    {

        
        static void Main(string[] args)

        {

            // Creates the text file that the trace listener will write to.
            System.IO.FileStream myTraceLog = new System.IO.FileStream("C:\\temp\\myTraceLog3.txt", System.IO.FileMode.OpenOrCreate);
            // Creates the new trace listener.
            System.Diagnostics.TextWriterTraceListener myListener = new System.Diagnostics.TextWriterTraceListener(myTraceLog);
            Trace.Listeners.Add(myListener);


            string DomainName = "FoxDeploy.local";
            string MPHostname = "SCCM.FoxDeploy.local";
            String machineName = System.Environment.MachineName;
            Console.WriteLine(machineName);

            string ClientName = "HamHam123";
            Console.WriteLine("Connecting from " + ClientName);
            SimulateClient(MPHostname, ClientName, DomainName);

        }
       
    static void SimulateClient(string MPHostname, string ClientName, string DomainName)
        {
            HttpSender sender = new HttpSender();

            // Load the certificate for client authentication
            //Password for excerpted cert
            using (MessageCertificateX509Volatile certificate = new MessageCertificateX509Volatile("c:\\temp\\MixedModeTestCert.pfx", "Pa$$w0rd!"))

            {
                Console.WriteLine(@"Using certificate for client authentication with thumbprint of '{0}'", certificate.Thumbprint);
                // Create a registration request
                ConfigMgrRegistrationRequest registrationRequest = new ConfigMgrRegistrationRequest();

                // Add our certificate for message signing
                registrationRequest.AddCertificateToMessage(certificate, CertificatePurposes.All);
                
                // Set the destination hostname
                registrationRequest.Settings.HostName = MPHostname;

                Console.WriteLine("Trying to reach: " + MPHostname);

                // Discover local properties for registration metadata
                registrationRequest.Discover();
                registrationRequest.AgentIdentity = "MyCustomClient.exe";
                registrationRequest.ClientFqdn = ClientName + "." + DomainName;
                registrationRequest.NetBiosName = ClientName;                  
                registrationRequest.HardwareId = Guid.NewGuid().ToString();
                Console.WriteLine("About to try to register" + registrationRequest.ClientFqdn);

                // Register client and wait for a confirmation with the SMSID

                //registrationRequest.Settings.Security.AuthenticationType = AuthenticationType.WindowsAuth;

                registrationRequest.Settings.Compression = MessageCompression.Zlib;
                registrationRequest.Settings.ReplyCompression = MessageCompression.Zlib;

                SmsClientId clientId = registrationRequest.RegisterClient(sender, TimeSpan.FromMinutes(5));
                Console.WriteLine(@"Got SMSID from registration of: {0}", clientId);

                // Send data to the site
                ConfigMgrDataDiscoveryRecordMessage ddrMessage = new ConfigMgrDataDiscoveryRecordMessage();


                // Add necessary discovery data
                ddrMessage.SmsId = clientId;
                ddrMessage.ADSiteName = "Default-First-Site-Name"; //Changed from 'My-AD-SiteName
                ddrMessage.SiteCode = "F0X";
                ddrMessage.DomainName = DomainName;
                Console.WriteLine("ddrSettings clientID: " + clientId);
                Console.WriteLine("ddrSettings SiteCode: " + ddrMessage.SiteCode);
                Console.WriteLine("ddrSettings ADSiteNa: " + ddrMessage.ADSiteName);
                Console.WriteLine("ddrSettings DomainNa: " + ddrMessage.DomainName);
                Console.WriteLine("Message MPHostName  : " + MPHostname);

                // Now create inventory records from the discovered data (optional)
                ddrMessage.Discover();
                
                // Add our certificate for message signing
                ddrMessage.AddCertificateToMessage(certificate, CertificatePurposes.Signing);
                ddrMessage.AddCertificateToMessage(certificate, CertificatePurposes.Encryption);
                ddrMessage.Settings.HostName = MPHostname;
                // Now send the message to the MP (it's asynchronous so there won't be a reply)
                ddrMessage.SendMessage(sender);

            }
        }
    }
}


