import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "form", "addressLine1", "addressLine2", "addressCity", "addressState", "addressPostalCode", "addressCountryCode", "phone", "dobDay", "dobMonth", "dobYear", "email", "firstName", "lastName", "maidenName", "gender", "tokenAccount" ]

  connect() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));
    // handleFormSubmission(); // eventually - move all the below into a neater function...
    form.addEventListener('submit', async function (event) {
      event.preventDefault();

      const accountResult = await stripe.createToken("account", {
        business_type: "individual",
        individual: {
          address: {
            line1: controller.addressLine1Target.value, // document.querySelector("#address_line1").value,
            line2: controller.addressLine2Target.value, // document.querySelector("#address_line2").value,
            city: controller.addressCityTarget.value, // document.querySelector("#address_city").value,
            state: controller.addressStateTarget.value, // document.querySelector("#address_state").value,
            postal_code: controller.addressPostalCodeTarget.value, // document.querySelector("#address_postal_code").value,
            country: controller.addressCountryCodeTarget.value // document.querySelector("#address_country_code").value
          },
          dob: {
            day: controller.dobDayTarget.value, // document.querySelector("#dob_day").value,
            month: controller.dobMonthTarget.value, // document.querySelector("#dob_month").value,
            year: controller.dobYearTarget.value // document.querySelector("#dob_year").value,
          },
          email: controller.emailTarget.value, // document.querySelector("#email").value,
          first_name: controller.firstNameTarget.value, // document.querySelector("#first_name").value,
          last_name: controller.lastNameTarget.value, // document.querySelector("#last_name").value,
          gender: controller.genderTarget.value, // document.querySelector("#gender").value,
          maiden_name: controller.maidenNameTarget.value// document.querySelector("#maiden_name").value,
          //phone: document.querySelector("#phone").value // "Not a valid phone number"
        },
        // exernal_account: { // TODO: need to use this: https://stripe.com/docs/api/tokens/create_bank_account
        //   account_number: document.querySelector("#stripe_account_bank_account_number").value,
        //   country: document.querySelector("#stripe_account_individual_address_country_code").value,
        //   currency: document.querySelector("#stripe_account_default_currency").value,
        //   object: "bank_account"
        // },
        tos_shown_and_accepted: true,
      });

      if (accountResult.token) {
        controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
        form.submit();
      }
    });
  }
}
