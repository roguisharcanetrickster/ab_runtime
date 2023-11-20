# Restore files.
# runtime
git restore .

# ab_platform_web
cd ./developer/ab_platform_web/AppBuilder/core
git restore .
cd ../../
git restore .
cd ../../

# api_sails
cd ./developer/api_sails
git restore .
cd ../../

# appbuilder
cd ./developer/appbuilder/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# bot_manager
cd ./developer/bot_manager
git restore .
cd ../../

# custom_reports
cd ./developer/custom_reports/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# db
cd ./developer/db
git restore .
cd ../../

# definition_manager
cd ./developer/definition_manager/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# file_processor
cd ./developer/file_processor/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# log_manager
cd ./developer/log_manager
git restore .
cd ../../

# migration_manager
cd ./developer/migration_manager
git restore .
cd ../../

# notification_email
cd ./developer/notification_email
git restore .
cd ../../

# plugins/ABDesigner
cd ./developer/plugins/ABDesigner
git restore .
cd ../../../

# process_manager
cd ./developer/process_manager/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# relay
cd ./developer/relay
git restore .
cd ../../

# tenant_manager
cd ./developer/tenant_manager
git restore .
cd ../../

# user_manager
cd ./developer/user_manager/AppBuilder/core
git restore .
cd ../
git restore .
cd ../
git restore .
cd ../../

# web
cd ./developer/web
rm -rf ./assets
git restore .
cd ../../

# Update repos
# runtime
git pull

# services
appbuilder update dev

# Update npm packages
# runtume
npm install -f

# ab_platform_web
cd ./developer/ab_platform_web
npm install -f
cd ../../

# api_sails
cd ./developer/api_sails
npm install -f
cd ../../

# appbuilder
cd ./developer/appbuilder/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# bot_manager
cd ./developer/bot_manager
npm install -f
cd ../../

# custom_reports
cd ./developer/custom_reports/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# db

# definition_manager
cd ./developer/definition_manager/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# file_processor
cd ./developer/file_processor/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# log_manager
cd ./developer/log_manager
npm install -f
cd ../../

# migration_manager
cd ./developer/migration_manager
npm install -f
cd ../../

# notification_email
cd ./developer/notification_email
npm install -f
cd ../../

# plugins/ABDesigner
cd ./developer/plugins/ABDesigner
npm install -f
cd ../../../

# process_manager
cd ./developer/process_manager/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# relay
cd ./developer/relay
npm install -f
cd ../../

# tenant_manager
cd ./developer/tenant_manager
npm install -f
cd ../../

# user_manager
cd ./developer/user_manager/AppBuilder
npm install -f
cd ../
npm install -f
cd ../../

# web
cd ./developer/web
npm install -f
cd ../../
