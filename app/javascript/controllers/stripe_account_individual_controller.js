// Ref: https://stripe.com/docs/api/tokens/create_account
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "businessDetailsWrapper", "dateOfBirth", "email",
                    "firstName", "form", "gender", "lastName",
                    "personalDetailsWrapper", "phone", "requiredBusiness",
                    "requiredPersonal", "stripeTosCheckBox", "submitBtn",
                    "tokenAccount"]

  connect() {
    this.addFormSubmissionHandler();
    this.enableSubmitBtn();
  }

  addFormSubmissionHandler() {
    const controller = this;
    this.formTarget.addEventListener("submit", async function (event) {
      event.preventDefault();

      if (controller.allBusinessFieldsComplete()) {
        controller.requestStripeTokenAndSubmitForm();
      } else {
        controller.showValidationErrors();
      }
    });
  }

  allBusinessFieldsComplete() {
    return this.requiredBusinessTargets.
      every((requiredField) => requiredField.value.length != 0);
  }

  allPersonalFieldsComplete() {
    return this.requiredPersonalTargets.
      every((requiredField) => requiredField.value.length != 0);
  }

  enableSubmitBtn() {
    this.submitBtnTarget.disabled = this.stripeTosCheckBoxTarget.checked;
  }

  proceedIfValid() {
    if (this.allPersonalFieldsComplete()) {
      this.personalDetailsWrapperTarget.classList.add("d-none");
      this.businessDetailsWrapperTarget.classList.remove("d-none");
    } else {
      this.showValidationErrors();
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
          day: controller.dateOfBirthTarget.value.split("-")[2],
          month: controller.dateOfBirthTarget.value.split("-")[1],
          year: controller.dateOfBirthTarget.value.split("-")[0]
        },
        email: controller.emailTarget.value,
        first_name: controller.firstNameTarget.value,
        gender: controller.genderTarget.value,
        last_name: controller.lastNameTarget.value
        //phone: document.querySelector("#phone").value // "Not a valid phone number"
      },
      tos_shown_and_accepted: true,
    });

    if (accountResult.token) {
      controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
      form.submit();
    }
  }

  showValidationErrors() {
    this.requiredPersonalTargets.forEach(this.toggleValidationError);
    this.requiredBusinessTargets.forEach(this.toggleValidationError);
  }

  toggleValidationError(target) {
    if (target.value.length == 0) {
      target.nextElementSibling.classList.remove("d-none");
    } else {
      target.nextElementSibling.classList.add("d-none");
    }
  }  
}
