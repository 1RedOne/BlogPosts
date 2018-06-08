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
            System.IO.FileStream myTraceLog = new System.IO.FileStream("C:\\temp\\myTraceLog.txt", System.IO.FileMode.OpenOrCreate);
            // Creates the new trace listener.
            System.Diagnostics.TextWriterTraceListener myListener = new System.Diagnostics.TextWriterTraceListener(myTraceLog);
            Trace.Listeners.Add(myListener);


            string DomainName = "FoxDeploy.local";
            string MPHostname = "SCCM.FoxDeploy.local";
            string ClientName = "FoxDeployTest2";

            SimulateClient(MPHostname, ClientName, DomainName);

        }

        static void SimulateClient(string MPHostname, string ClientName, string DomainName)
        {
            HttpSender sender = new HttpSender();

            // Load the certificate for client authentication
            //Password for excerpted cert
            using (MessageCertificateX509Volatile certificate = new MessageCertificateX509Volatile(File.ReadAllBytes("c:\\temp\\MixedModeTestCert.pfx"), "Pa$$w0rd!"))

            {
                // Create a registration request
                ConfigMgrRegistrationRequest registrationRequest = new ConfigMgrRegistrationRequest();

                // Add our certificate for message signing
                registrationRequest.AddCertificateToMessage(certificate, CertificatePurposes.Signing);

                // Set the destination hostname
                registrationRequest.Settings.HostName = MPHostname;


                // Discover local properties for registration metadata
                registrationRequest.Discover();

                registrationRequest.ClientFqdn = ClientName + "." + DomainName;
                registrationRequest.NetBiosName = ClientName;
                registrationRequest.AgentIdentity = "MySampleApp";


                // Register client and wait for a confirmation with the SMSID

                SmsClientId clientId = registrationRequest.RegisterClient(sender, TimeSpan.FromMinutes(5));

                // Send data to the site
                ConfigMgrDataDiscoveryRecordMessage ddrMessage = new ConfigMgrDataDiscoveryRecordMessage();


                // Add necessary discovery data
                ddrMessage.SmsId = clientId;
                ddrMessage.ADSiteName = "MyADSite";
                ddrMessage.SiteCode = "F0X";
                ddrMessage.DomainName = DomainName;

                // Now create inventory records from the discovered data (optional)
                ddrMessage.Discover();

                // Add our certificate for message signing
                ddrMessage.AddCertificateToMessage(certificate, CertificatePurposes.Signing);
                ddrMessage.Settings.HostName = MPHostname;
                // Now send the message to the MP (it's asynchronous so there won't be a reply)
                ddrMessage.SendMessage(sender);

            }
        }
    }
}


