// Ref: https://stripe.com/docs/api/tokens/create_account
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addressLine1", "addressLine1Error", "addressLine2",
                    "addressLine2Error", "addressCity", "addressCityError",
                    "addressState", "addressStateError", "addressPostalCode",
                    "addressPostalCodeError", "addressCountry",
                    "addressCountryError", "businessDetails", "dateOfBirth",
                    "dateOfBirthError", "email", "emailError", "firstName",
                    "firstNameError", "form", "gender", "genderError", "lastName",
                    "lastNameError", "personalDetails", "phone", "phoneError",
                    "submitBtn", "tokenAccount"]

  // TODO: loop thru: requiredPersonalDetails where we need to....
  static requiredPersonalDetails = [this.emailTarget, this.firstNameTarget,
                                    this.lastNameTarget, this.dateOfBirthTarget]

  connect() {
    this.addFormSubmissionHandler();
  }

  addFormSubmissionHandler() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));

    form.addEventListener("submit", async function (event) {
      event.preventDefault();

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
    });
  }

  allPersonalFieldsComplete() {
    // TODO: loop thru: requiredPersonalDetails and check that...
    if(this.isEmpty(this.emailTarget) || this.isEmpty(this.firstNameTarget) ||
        this.isEmpty(this.lastNameTarget) || this.isEmpty(this.dateOfBirthTarget)) {
      return false;
    } else {
      return true;
    }
  }

  isEmpty(el) {
    return el.value.length === 0;
  }

  enableSubmitBtn(el) {
    if (el.target.checked) { 
      this.submitBtnTarget.disabled = false;
    } else {
      this.submitBtnTarget.disabled = true;
    }
  }

  proceedIfValid() {
    if (this.allPersonalFieldsComplete()) {
      this.personalDetailsTargets.forEach(function(target) { target.classList.add("d-none"); });
      this.businessDetailsTargets.forEach(function(target) { target.classList.remove("d-none"); });
    } else {
      this.showValidationErrors();
    }
  }

  showValidationErrors() {
    // TODO: loop thru: requiredPersonalDetails and check that...
    if(this.isEmpty(this.emailTarget)) {
      this.emailTarget.classList.add("is-invalid");
      this.emailErrorTarget.classList.remove("d-none");
    } else {
      this.emailTarget.classList.add("is-valid");
      this.emailErrorTarget.classList.add("d-none");
    }

    if(this.isEmpty(this.firstNameTarget)) {
      this.firstNameTarget.classList.add("is-invalid");
      this.firstNameErrorTarget.classList.remove("d-none");
    } else {
      this.firstNameTarget.classList.add("is-valid");
      this.firstNameErrorTarget.classList.add("d-none");
    }

    if(this.isEmpty(this.lastNameTarget)) {
      this.lastNameTarget.classList.add("is-invalid");
      this.lastNameErrorTarget.classList.remove("d-none");
    } else {
      this.lastNameTarget.classList.add("is-valid");
      this.lastNameErrorTarget.classList.add("d-none");
    }

    if(this.isEmpty(this.dateOfBirthTarget)) {
      this.dateOfBirthTarget.classList.add("is-invalid");
      this.dateOfBirthErrorTarget.classList.remove("d-none");
    } else {
      this.dateOfBirthTarget.classList.add("is-valid");
      this.dateOfBirthErrorTarget.classList.add("d-none");
    }
  }
}
