const Config = require("../../../setup/config.js");

describe("Login Page", () => {
   before(() => {
      // make sure we have a clean slate before continuing.
      cy.exec("npm run test:reset");
   });

   // 1) Successful Login
   it("loads the login page", () => {
      cy.visit("/");
      Login(Config.tenant, Config.user.email, Config.user.password);
      cy.wait(3000); // a login will make you wait > 3s

      // warning should NOT exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("not.exist");

      // but the menu bar should
      cy.get("[data-cy=portal_work_menu_sidebar]");
   });

   // 2) Successful Logout
   it("Logging out, returns you to the Login Form:", () => {
      cy.get("[data-cy=user_icon]").click();
      cy.get("[data-cy=user_logout]").click();
      cy.get("[data-cy=portal_auth_login_form_tenantList]");
   });

   // 3) Login Error Messages
   it("Displays Error Message when invalid Username / Password", () => {
      Login(Config.tenant, `a${Config.user.email}`, Config.user.password);
      cy.wait(2000); // a login will make you wait > 3s

      // now the warning should exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("exist");
   });
});

function Login(tenant, email, passowrd) {
   cy.getCookies().should((cookie) => {
      console.log(cookie);
   });
   cy.get("[data-cy=portal_auth_login_form_tenantList]").select(tenant);
   cy.get("input[data-cy=portal_auth_login_form_email]").type(email);
   cy.get("input[data-cy=portal_auth_login_form_password]").type(passowrd);
   cy.get("[data-cy=portal_auth_login_form_submit]").click();
}
