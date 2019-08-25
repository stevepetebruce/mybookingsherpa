// Ref: https://stripe.com/docs/api/tokens/create_bank_account
import { StripeBaseController } from "./stripe_base_controller";

export default class extends StripeBaseController {
  static targets = ["accountHolderName", "accountHolderType", "accountNumber",
                    "country", "currency", "form", "routingNumber", "submitBtn",
                    "tokenAccount"]

  connect() {
    this.addFormSubmissionHandler();
  }

  addFormSubmissionHandler() {
    const controller = this;
    const form = this.formTarget;
    const stripe = Stripe(this.data.get("key"));

    form.addEventListener("submit", async function (event) {
      event.preventDefault();

      const accountResult = await stripe.createToken("bank_account", {
        account_holder_name: controller.accountHolderNameTarget.value,
        account_holder_type: controller.accountHolderTypeTarget.value,
        account_number: controller.accountNumberTarget.value,
        country: controller.countryTarget.value,
        currency: controller.currencyTarget.value,
        routing_number: controller.routingNumberTarget.value
      });

      if (accountResult.token) {
        controller.tokenAccountTarget.setAttribute("value", accountResult.token.id);
        form.submit();
      }
      if (accountResult.error) {
        controller.showStripeApiError(accountResult.error);
      }
    });
  }

  hideErrorEnableSubmitBtn(event) {
    this.hideError(event);
    this.enableSubmitBtn();
  }

  hideError(event) {
    event.target.nextElementSibling.classList.add("d-none");
  }

  enableSubmitBtn() {
    this.submitBtnTarget.disabled = false;
  }
}
