import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["accountHolderName", "accountHolderType", "accountNumber", "countryCode", "currency", "form", "routingNumber", "tokenAccount"]

  connect() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));
    form.addEventListener("submit", async function (event) {
      event.preventDefault();

      const accountResult = await stripe.createToken("bank_account", {
        country: controller.countryCodeTarget.value,
        currency: controller.currencyTarget.value,
        account_holder_name: controller.accountHolderNameTarget.value,
        account_holder_type: controller.accountHolderTypeTarget.value,
        routing_number: controller.routingNumberTarget.value,
        account_number: controller.accountNumberTarget.value
      });

      if (accountResult.token) {
        controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
        form.submit();
      }
    });
  }
}
