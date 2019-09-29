// Ref: https://stripe.com/docs/api/tokens/create_account
import { StripeBaseController } from "./base_controller";

export default class extends StripeBaseController {
  static targets = ["addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "businessDetailsWrapper", "dob", "email",
                    "firstName", "form", "lastName",
                    "personalDetailsWrapper", "phone", "progressBar",
                    "progressDot", "requiredBusiness", "requiredPersonal",
                    "submitBtn", "tokenAccount"]

  connect() {
    this.addFormSubmissionHandler();
  }

  addFormSubmissionHandler() {
    const controller = this;
    this.formTarget.addEventListener("submit", async function (event) {
      event.preventDefault();

      if (controller.allBusinessFieldsComplete()) {
        controller.requestStripeTokenAndSubmitForm();
      } else {
        controller.showEmptyFieldsErrors();
      }
    });
  }

  allBusinessFieldsComplete() {
    return this.requiredBusinessTargets.
      every((requiredField) => requiredField.value.length !== 0);
  }

  allPersonalFieldsComplete() {
    return this.requiredPersonalTargets.
      every((requiredField) => requiredField.value.length !== 0);
  }

  proceedIfValid() {
    if (this.allPersonalFieldsComplete()) {
      this.progressBarTarget.style.width = "61%";
      this.progressDotTarget.classList.add("primary-color");
      this.progressDotTarget.classList.remove("no-color");
      this.personalDetailsWrapperTarget.classList.add("d-none");
      this.businessDetailsWrapperTarget.classList.remove("d-none");
    } else {
      this.showEmptyFieldsErrors();
    }
  }

  async requestStripeTokenAndSubmitForm() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));

    const accountResult = await stripe.createToken("account", {
      business_type: "individual",
      individual: {
        address: {
          line1: controller.addressLine1Target.value,
          line2: controller.addressLine2Target.value,
          city: controller.addressCityTarget.value,
          state: controller.addressStateTarget.value,
          postal_code: controller.addressPostalCodeTarget.value,
          country: controller.addressCountryTarget.value
        },
        dob: {
          day: controller.dobTarget.value.split("-")[2],
          month: controller.dobTarget.value.split("-")[1],
          year: controller.dobTarget.value.split("-")[0]
        },
        email: controller.emailTarget.value,
        first_name: controller.firstNameTarget.value,
        last_name: controller.lastNameTarget.value
        //phone: document.querySelector("#phone").value // "Not a valid phone number"
      },
      tos_shown_and_accepted: true,
    });

    if (accountResult.token) {
      controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
      form.submit();
    }

    if (accountResult.error) {
      this.showStripeApiError(accountResult.error, true);
      this.enableSubmitBtn();
    }
  }

  showEmptyFieldsErrors() {
    this.requiredPersonalTargets.forEach(this.toggleEmptyFieldErrMsg);
    this.requiredBusinessTargets.forEach(this.toggleEmptyFieldErrMsg);
  }

  toggleEmptyFieldErrMsg(target) {
    if (target.value.length === 0) {
      target.nextElementSibling.classList.remove("d-none");
    } else {
      target.nextElementSibling.classList.add("d-none");
    }
  }  
}
