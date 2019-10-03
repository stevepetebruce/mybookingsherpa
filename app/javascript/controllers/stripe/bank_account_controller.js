// Ref: https://stripe.com/docs/api/tokens/create_bank_account
import { StripeBaseController } from "./base_controller";

export default class extends StripeBaseController {
  static targets = ["accountHolderName", "accountHolderType", "accountNumber",
                    "country", "currency", "formDetails", "formToken",
                    "required", "routingNumber", "submitBtn", "tokenAccount"]

  connect() {
    this.handleFormSubmission();
  }

  allFieldsComplete() {
    return this.requiredTargets.
      every((requiredField) => requiredField.value.length !== 0);
  }

  handleFormSubmission() {
    this.formDetailsTarget.addEventListener("submit", async (event) => {
      event.preventDefault();

      if (this.allFieldsComplete()) {
        this.requestStripeTokenAndSubmitForm();
      } else {
        this.showEmptyFieldsErrors();
      }
    });
  }

  hideError(event) {
    event.target.nextElementSibling.classList.add("d-none");
  }

  hideErrorEnableSubmitBtn(event) {
    this.hideError(event);
    this.enableSubmitBtn();
  }

  async requestStripeTokenAndSubmitForm() {
    const stripe = Stripe(this.data.get("key"));

    const {token, error} = await stripe.createToken("bank_account", {
      account_holder_name: this.accountHolderNameTarget.value,
      account_holder_type: this.accountHolderTypeTarget.value,
      account_number: this.accountNumberTarget.value,
      country: this.countryTarget.value,
      currency: this.currencyTarget.value,
      routing_number: this.routingNumberTarget.value
    });

    if (error) {
      this.showStripeApiError(error);
    } else {
      this.tokenAccountTarget.setAttribute("value", token.id);
      this.formTokenTarget.submit();
    }
  }

  showEmptyFieldsErrors() {
    this.requiredTargets.forEach(this.toggleEmptyFieldErrMsg);
  }

  toggleEmptyFieldErrMsg(target) {
    if (target.value.length === 0) {
      target.nextElementSibling.classList.remove("d-none");
    } else {
      target.nextElementSibling.classList.add("d-none");
    }
  }

  updateCountryCurrency() {
    switch(this.countryTarget.value) {
      case "GB":
        this.currencyTarget.value = "gbp";
        break;
      case "US":
        this.currencyTarget.value = "usd";
        break;
      default:
        this.currencyTarget.value = "eur";
    }     
  }
}
