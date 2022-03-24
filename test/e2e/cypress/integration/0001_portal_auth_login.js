const Config = require("../../../setup/config.js");
const Common = require("../../../setup/common.js");

// Don't stop tests on uncaught errors
Cypress.on("uncaught:exception", () => false);

describe("Login Page", () => {
   before(() => {
      // make sure we have a clean slate before continuing.
      Common.ResetDB(cy);
   });

   beforeEach(() => {
      cy.visit("/");
   });

   // 1) Successful Login
   it("loads the login page", () => {
      Login(Config.tenant, Config.user.email, Config.user.password);

      // warning should NOT exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("not.exist");

      // but the menu bar should
      cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible");
   });

   // 2) Successful Logout
   it("Logging out, returns you to the Login Form:", () => {
      Login(Config.tenant, Config.user.email, Config.user.password);
      cy.get("[data-cy=user_icon]").should("be.visible").click();
      cy.get("[data-cy=user_logout]").should("be.visible").click();
      cy.get("[data-cy=portal_auth_login_form_tenantList]").should(
         "be.visible"
      );
   });

   // 3) Login Error Messages
   it("Displays Error Message when invalid Username / Password", () => {
      Login(Config.tenant, `a${Config.user.email}`, Config.user.password);

      // now the warning should exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("exist");
   });
});

function Login(tenant, email, passowrd) {
   cy.getCookies().should((cookie) => {
      console.log(cookie);
   });
   cy.get("[data-cy=portal_auth_login_form_tenantList]")
      .should("be.visible")
      .select(tenant);
   cy.get("input[data-cy=portal_auth_login_form_email]").type(email);
   cy.get("input[data-cy=portal_auth_login_form_password]").type(passowrd);
   cy.get("[data-cy=portal_auth_login_form_submit]").click();
}
