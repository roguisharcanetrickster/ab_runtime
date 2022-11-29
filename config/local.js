/**
 * Local environment settings
 *
 * Use this file to specify configuration settings for use while developing
 * the app on your personal system.
 *
 * For more information, check out:
 * https://sailsjs.com/docs/concepts/configuration/the-local-js-file
 */
var path = require("path");

module.exports = {
   // Any configuration settings may be overridden below, whether it's built-in Sails
   // options or custom configuration specifically for your app (e.g. Stripe, Mailgun, etc.)

   /**
    * CAS authentication
    */
   cas: {
      enabled: process.env.CAS_ENABLED == "true" ? true : false,
      baseURL: process.env.CAS_BASE_URL,
      uuidKey: process.env.CAS_UUID_KEY,
      siteURL: process.env.SITE_URL
   },

   /**
    * Okta authentication
    */
   okta: {
      enabled: process.env.OKTA_ENABLED == "true" ? true : false,
      domain: process.env.OKTA_DOMAIN,
      clientID: process.env.OKTA_CLIENT_ID,
      clientSecret: process.env.OKTA_CLIENT_SECRET,
      siteURL: process.env.SITE_URL
   },

   /**
    * datastores:
    * Sails style DB connection settings
    */
   datastores: {
    "appbuilder": {
      "adapter": "sails-mysql",
      "host": "db",
      "port": 3306,
      "user": "root",
      "password": process.env.MYSQL_PASSWORD,
      "database": "appbuilder",
      "poolmax": 40
    },
    "site": {
      "adapter": "sails-mysql",
      "host": "db",
      "port": 3306,
      "user": "root",
      "password": process.env.MYSQL_PASSWORD,
      "database": "appbuilder-admin"
    }
  },
  /* end datastores */

   /**
    * appbuilder
    * service for managing our multi-tenant aware AB requests
    */
   appbuilder: {
      enable: true,
   },
   /* end appbuilder */

   /**
    * bot_manager:
    * define the connections between our bot_manager and the host command
    * processor.
    */
   bot_manager: {
    "dockerHub": {
      "enable": false,
      "port": 14000
    },
    "slackBot": {
      "enable": false
    },
    "hostConnection": {
      "tcp": {
        "port": 1338,
        "accessToken": "D19GyPzzCA0IJbeGtSQEY"
      }
    },
    "stackName": "stack_name",
    "triggers": [
      { search: /skipdaddy\/.*:develop/, command: "update", options: {} }
    ]
  },
  /* end bot_manager */

   
   /**
    * custom_reports
    */
   custom_reports: {
      enable: process.env.CUSTOM_REPORTS_ENABLED == "true" ? true : false,
   },
   /* end custom_reports */
   
   /**
    * definition_manager
    * service for managing our multi-tenant aware AB requests
    */
   definition_manager: {
      enable: true,
   },
   /* end definition_manager */

   /**
    * file_processor
    * our file manager
    */
   file_processor: {
      enable: true,
      basePath: path.sep + path.join("data"),
      // final dest: /data/[tenant.ID]/file_processor/[file]
      uploadPath: "tmp",
   },
   /* end file_processor */

   /**
    * log_manager
    * service for managing our various logs
    */
   log_manager: {
      enable: true,
      sentry: process.env.SENTRY_ENABLED == "true" ? {
         dsn: process.env.SENTRY_DSN,
         // We recommend adjusting this value in production, or using tracesSampler
         // for finer control
         tracesSampleRate: Number(process.env.SENTRY_SAMPLE_RATE ?? 1.0),
         serverName: process.env.SENTRY_SERVER_NAME,
      } : undefined,
   },
   /* end log_manager */

   /**
    * notification_email
    * our smtp email service
    */
   notification_email: {
      "enable": false,
      "default": "smtp",
      "smtp": {}
   },
  /* end notification_email */

   /**
    * process_manager
    * manages processes
    */
   process_manager: {
      enable: true,
   },
   /* end process_manager */

   /**
    * relay
    */
   relay: {
      enable: process.env.RELAY_ENABLED == "true" ? true : false,
      mcc: {
         enabled: process.env.RELAY_ENABLED == "true" ? true : false,
         url: process.env.RELAY_SERVER_URL,
         accessToken: process.env.RELAY_SERVER_TOKEN,
         pollFrequency: process.env.RELAY_POLL_FREQUENCY ?? 1000 * 5, // 5s
         maxPacketSize: process.env.RELAY_MAX_PACKET_SIZE ?? 1024 * 1024,
      },
      pwaURL: process.env.PWA_URL,
   },

   /**
    * tenant_manager
    * manages the different tenants in our system
    */
   tenant_manager: {
      enable: true,
      // {bool} enable the tenant_manager service.
      // don't turn this off.  You wont like it if you turn it off.

      siteTenantID: "admin",
      // {string} the uuid of what is considered the "Admin" Tenant.
      // this resolves to the Tenant Manager Site, and is established on
      // install.  It can be reconfigured ... but only if you know what
      // you are doing.
      // You have been warned ...
   },
   /* end tenant_manager */

   /**
    * user_manager
    * manage the users withing a tenant
    */
   user_manager: {
      enable: true,
   },
   /* end user_manager */
};
