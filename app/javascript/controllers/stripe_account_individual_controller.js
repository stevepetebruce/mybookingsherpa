import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "businessDetails", "dateOfBirth", "email", "firstName",
                    "form", "gender", "lastName", "personalDetails", "phone",
                    "submitBtn", "tokenAccount"]

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

  enableSubmitBtn(el) {
    if (el.target.checked) { 
      this.submitBtnTarget.disabled = false;
    } else {
      this.submitBtnTarget.disabled = true;
    }
  }

  toggleDetails() {
    this.personalDetailsTargets.forEach(function(target) { target.classList.add("d-none"); });
    this.businessDetailsTargets.forEach(function(target) { target.classList.remove("d-none"); });
  }
}
