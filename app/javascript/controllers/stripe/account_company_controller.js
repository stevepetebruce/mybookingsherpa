import { Controller } from "stimulus"

// formDetails - the form that gets sent to Stripe
// formToken - the form (with only the account token in) that gets sent to us
export default class extends Controller {
  static targets = ["acceptedTosError", "addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "formDetails", "formToken", "name", "phone", "stripeTosCheckBox",
                     "taxId", "submitBtn", "tokenAccount", "vatId"] // TODO: need to send the vat/ tax id to stripe

  connect() {
    this.handleFormSubmission();
  }

  enableSubmitBtn() {
    this.submitBtnTarget.disabled = false;
  }

  handleFormSubmission() {
    const stripe = Stripe(this.data.get("key"));

    this.formDetailsTarget.addEventListener("submit", async (event) => {
      event.preventDefault();

      if(!this.stripeTosAccepted()) {
        this.enableSubmitBtn();
        return;
      }

      // ref: https://stripe.com/docs/api/tokens/create_account
      const accountResult = await stripe.createToken("account", {
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

      if (accountResult.token) {
        this.tokenAccountTarget.setAttribute("value", accountResult.token.id);
        this.formTokenTarget.submit();
      } // TODO: else - handle errors
    });
  }

  hideError() {
    event.target.nextElementSibling.classList.add("d-none");
  }

  hideErrorEnableSubmitBtn() {
    this.hideError(event);
    this.enableSubmitBtn();
  }

  taxId() {
    if (this.hasTaxIdTarget) {
      return this.taxIdTarget.value;
    }
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

  vatId() {
    if (this.hasVatIdTarget) {
      return this.vatIdTarget.value;
    }
  }
}