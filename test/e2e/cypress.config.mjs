import { defineConfig } from "cypress";

export default defineConfig({
   defaultCommandTimeout: 30000,
   responseTimeout: 90000,
   video: false,
   e2e: {
      testIsolation: false,
      setupNodeEvents(/* on, config */) {
         // implement node event listeners here
      },
   },
});
