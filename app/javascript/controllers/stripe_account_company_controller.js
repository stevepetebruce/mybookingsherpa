import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "form", "name", "phone", "tax_id", "tokenAccount",
                    "vat_id"]

  connect() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));
    // handleFormSubmission(); // eventually - move all the below into a neater function...
    form.addEventListener('submit', async function (event) {
      event.preventDefault();
      // ref: https://stripe.com/docs/api/tokens/create_account
      const accountResult = await stripe.createToken("account", {
        business_type: "company",
        company: {
          name: controller.nameTarget.value,
          address: {
            line1: controller.addressLine1Target.value,
            line2: controller.addressLine2Target.value,
            city: controller.addressCityTarget.value,
            state: controller.addressStateTarget.value,
            postal_code: controller.addressPostalCodeTarget.value,
            country: controller.addressCountryTarget.value
          },
        },
        tos_shown_and_accepted: true,
      });

      if (accountResult.token) {
        controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
        form.submit();
      }
    });
  }
}
