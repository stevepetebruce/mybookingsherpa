import { StripeBaseController } from "./base_controller";

// formDetails - the form that gets sent to Stripe
// formToken - the form (with only the account token in) that gets sent to us
export default class extends StripeBaseController {
  static targets = ["acceptedTosError", "addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "formDetails", "formToken", "name", "phone", "requiredBusiness",
                    "stripeTosCheckBox", "submitBtn", "taxId", "tokenAccount", "vatId"] // TODO: need to send the vat/ tax id to stripe

  connect() {
    this.handleFormSubmission();
  }

  allBusinessFieldsComplete() {
    return this.requiredBusinessTargets.
      every((requiredField) => requiredField.value.length !== 0);
  }

  enableSubmitBtn() {
    this.submitBtnTarget.disabled = false;
  }

  handleFormSubmission() {
    this.formDetailsTarget.addEventListener("submit", async (event) => {
      event.preventDefault();

      if(!this.stripeTosAccepted()) {
        this.enableSubmitBtn();
        return;
      }

      if (this.allBusinessFieldsComplete()) {
        this.requestStripeTokenAndSubmitForm();
      } else {
        this.showEmptyFieldsErrors();
      }
    });
  }

  hideError() {
    event.target.nextElementSibling.classList.add("d-none");
  }

  hideErrorEnableSubmitBtn() {
    this.hideError(event);
    this.enableSubmitBtn();
  }

  async requestStripeTokenAndSubmitForm() {
    // ref: https://stripe.com/docs/api/tokens/create_account
    const stripe = Stripe(this.data.get("key"));

    const {token, error} = await stripe.createToken("account", {
      business_type: "company",
      company: {
        name: this.nameTarget.value,
        address: {
          line1: this.addressLine1Target.value,
          line2: this.addressLine2Target.value,
          city: this.addressCityTarget.value,
          state: this.addressStateTarget.value,
          postal_code: this.addressPostalCodeTarget.value,
          country: this.addressCountryTarget.value
        },
        tax_id: this.taxId(),
        vat_id: this.vatId()
      },
      tos_shown_and_accepted: true,
    });

    if (error) {
      this.showStripeApiError(error);
      this.enableSubmitBtn();
    } else {
      this.tokenAccountTarget.setAttribute("value", token.id);
      this.formTokenTarget.submit();
    }
  }

  showEmptyFieldsErrors() {
    this.requiredBusinessTargets.forEach(this.toggleEmptyFieldErrMsg);
  }

  stripeTosAccepted() {
    if(this.stripeTosCheckBoxTarget.checked) {
      this.acceptedTosErrorTarget.classList.add("d-none");
      return true;
    } else {
      this.acceptedTosErrorTarget.classList.remove("d-none");
      return false;
    }
  }

  taxId() {
    if (this.hasTaxIdTarget) {
      return this.taxIdTarget.value;
    }
  }

  toggleEmptyFieldErrMsg(target) {
    if (target.value.length === 0) {
      target.nextElementSibling.classList.remove("d-none");
    } else {
      target.nextElementSibling.classList.add("d-none");
    }
  }

  vatId() {
    if (this.hasVatIdTarget) {
      return this.vatIdTarget.value;
    }
  }
}
