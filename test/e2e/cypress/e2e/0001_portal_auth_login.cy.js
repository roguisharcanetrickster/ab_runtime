// Don't stop tests on uncaught errors
Cypress.on("uncaught:exception", () => false);

describe("Login Page", () => {
   before(() => {
      // make sure we have a clean slate before continuing.
      cy.ResetDB();
   });

   beforeEach(() => {
      cy.visit("/");
   });

   // 1) Successful Login
   it("loads the login page", () => {
      Login(Cypress.env("USER_EMAIL"), Cypress.env("USER_PASSWORD"));

      // warning should NOT exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("not.exist");

      // but the menu bar should
      cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible");
   });

   // 2) Successful Logout
   it("Logging out, returns you to the Login Form:", () => {
      Login(Cypress.env("USER_EMAIL"), Cypress.env("USER_PASSWORD"));
      cy.get("[data-cy=user_icon]").should("be.visible").click();
      cy.get("[data-cy=user_logout]").should("be.visible").click();
   });

   // 3) Login Error Messages
   it.skip("Displays Error Message when invalid Username / Password", () => {
      Login(`a${Cypress.env("USER_EMAIL")}`, Cypress.env("USER_PASSWORD"));

      // now the warning should exist
      cy.get("[data-cy=portal_auth_login_form_errormsg]").should("exist");
   });
});

describe.skip("Loading", () => {
   before(() => {
      const url = Cypress.config("baseUrl");
      const parts = url.split("//");
      Cypress.config("baseUrl", `${parts[0]}//fake.${parts[1]}`);
   });
   it("shows error when tenant not found", () => {
      cy.visit("/", { failOnStatusCode: false });
      cy.contains("couldn't find the tenant 'fake'");
   });
});

function Login(email, passowrd) {
   cy.getCookies().should((cookie) => {
      console.log(cookie);
   });
   cy.get("input[data-cy=portal_auth_login_form_email]").type(email);
   cy.get("input[data-cy=portal_auth_login_form_password]").type(passowrd);
   cy.get("[data-cy=portal_auth_login_form_submit]").click();
}
