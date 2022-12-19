const Common = require("../../../setup/common.js");

const appclicationDefault = {
   name: "Test App",
   icon: "fa-500px",
   description: "This is a testing app.",
   isSystemObject: false,
   roles: [],
   enablePage: {
      byRole: [],
      byAccount: [],
      byField: [],
   },
   enableTranslation: {
      byRole: [],
      byAccount: [],
      byField: [],
   },
};

// Don't stop tests on uncaught errors
Cypress.on("uncaught:exception", () => false);

const NavigateABDesigner = (cy) => {
   cy.get("[data-cy=portal_work_menu_sidebar]").should("be.visible").click();
   cy.get("[data-cy=ABDesigner]").should("be.visible").click();
};

const NavigateABDesignerApplication = (cy, name) => {
   NavigateABDesigner(cy);
   cy.get('[view_id="abd_choose_list_list"]')
      .contains(name)
      .should("be.visible")
      .click();
};

describe("AB Designer:", () => {
   before(() => {
      Common.ResetDB(cy);
      Common.AuthLogin(cy);
      cy.visit("/");
   });

   describe("Main page", () => {
      before(() => {
         NavigateABDesigner(cy);
      });

      describe("New application", () => {
         it("Add new application", () => {
            cy.get('[data-cy="abd_choose_list_buttonCreateNewApplication"]')
               .should("exist")
               .click();
            cy.get('[data-cy="abd_choose_form_cancel"]')
               .should("exist")
               .click();
            cy.get('[view_id="abd_choose_list_list"]')
               .find(".webix_scroll_cont")
               .find(".webix_list_item")
               .should("have.length", 1);
            cy.get(
               '[data-cy="abd_choose_list_buttonCreateNewApplication"]'
            ).click();
            cy.get('[data-cy="abd_choose_form_label"]')
               .should("exist")
               .type(appclicationDefault.name);
            cy.get('[data-cy="abd_choose_form_icon"]').should("exist").click();
            cy.contains("fa-500px").should("exist").click();
            cy.get('[data-cy="abd_choose_form_description"]')
               .should("exist")
               .type(appclicationDefault.description);
            cy.get('[view_id="abd_choose_form_appFormPermissionList"]')
               .should("exist")
               .click();
            cy.contains("Select").click();
            cy.get('[data-cy="abd_choose_form_saveButton"]')
               .should("exist")
               .click();
            cy.get('[view_id="abd_choose_list_list"]')
               .contains(appclicationDefault.description)
               .should("be.visible");
            cy.get('[view_id="abd_choose_list_list"]')
               .find(`.${appclicationDefault.icon}`)
               .should("be.visible");
            cy.get('[view_id="abd_choose_list_list"]')
               .contains(appclicationDefault.name)
               .should("be.visible")
               .click();
            cy.get('[view_id="abd_work_labelAppName"]').should(
               "include.text",
               appclicationDefault.name
            );
         });

         it('Add new application with the "Is this a System Object?" option', () => {});

         it('Add new application with the "Enable Page / Tab Access Management" option', () => {});

         it('Add new application with the "Enable Translation Tool" option', () => {});
      });

      describe("Existing application", () => {
         it("Edit", () => {});

         it("Delete", () => {});
      });

      describe("Import and export", () => {
         it("Import", () => {});

         it("Export", () => {});

         it("Export All", () => {});
      });
   });

   describe("Application page", () => {
      before(() => {
         NavigateABDesignerApplication(appclicationDefault.name);
      });

      describe("Objects", () => {});

      describe("Queries", () => {});

      describe("Data Collections", () => {});

      describe("Process", () => {});

      describe("Interface", () => {});
   });
});
