const CommonLogin = require("../../../setup/commonLogin.js");

// var loggedInCookie = null;
var isAppImported = false;

describe("CARS:", () => {
   before(() => {
      cy.exec("npm run test:reset");
   });

   beforeEach(() => {
      CommonLogin(cy);
      if (!isAppImported) {
         isAppImported = true;
         cy.request("POST", "/test/import", {
            file: "imports/app_cars.json",
         });
      }
      /*
      if (!loggedInCookie) {
         cy.request("POST", "/auth/login", {
            tenant: Config.tenant, // "admin",
            email: Config.user.email, // "admin@email.com",
            password: Config.user.password, // "password",
         })
            .its("body")
            .as("currentUser");

         cy.getCookie("sails.sid").then((cookie) => {
            loggedInCookie = cookie;
         });

         if (!isAppImported) {
            isAppImported = true;
            cy.request("POST", "/test/import", {
               file: "imports/app_cars.json",
            });
         }
      } else {
         cy.setCookie(loggedInCookie.name, loggedInCookie.value);
      }
      */
   });

   it("has CARS app in the Nav Menu", () => {
      cy.visit("/").wait(1500);
      NavigateCars(cy);

      // Should show CARS in the Menu Title
      cy.get("[data-cy=portal_work_menu_title]")
         .should("be.visible")
         .should("have.text", "CARS");

      // Should have 2 pages
      cy.get("[data-cy=portal_work_menu_pages]").then((elContainer) => {
         expect(elContainer[0].childElementCount).to.equal(2);
      });
   });
});

function NavigateCars(cy) {
   cy.get("[data-cy=portal_work_menu_sidebar]").click();
   cy.get("[data-cy=45c62df9-ddd6-4744-84d6-50a2d549289d]").click();
}
