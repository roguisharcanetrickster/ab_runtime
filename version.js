// This is meant to be the most recent production ready versions of services that
// work together.
// This file will be autoupdated when a service is updated and passes end-to-end tests.
// To update to the latest version run `git pull` then `node dockerImageUpdate`
// FORMAT .services: {
//  <service>:<docker_tag>
// }

module.exports = {
   meta_version: "0.1.0",
   services: {
      api_sails: "develop",
      appbuilder: "develop",
      db: "master",
      web: "master",
      custom_reports: "develop",
      definition_manager: "develop",
      file_processor: "develop",
      log_manager: "develop",
      notification_email: "develop",
      process_manager: "develop",
      relay: "develop",
      tenant_manager: "develop",
      user_manager: "develop",
   },
};
