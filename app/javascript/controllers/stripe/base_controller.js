// Handle all common Stripe API functionality
import { Controller } from "stimulus";

export class StripeBaseController extends Controller {
  allDetails() {
    return this.bankDetails().concat(this.businessDetails(), this.personalDetails());
  }

  bankDetails() {
    return ["account_number", "account_holder_name", "account_holder_type",
            "country", "currency", "routing_number"];
  }

  businessDetails() {
    return ["addressLine1", "addressLine2", "addressCity", "addressState",
            "addressPostalCode", "addressCountry"];
  }

  enableSubmitBtn() {
    this.submitBtnTarget.disabled = false;
  }

  personalDetails() {
    return ["dob", "email", "firstName", "lastName"];
  }

  possibleFieldsWithErr(errMsg) {
    // ex: "account[individual][dob][year]" -> ["individual", dob", "year"]
    return errMsg.split("[").map((x) => { return x.replace("]",""); });
  }

  togglePersonalBusinessDetails(fieldWithError) {
    const _fieldWithError = String(fieldWithError);

    if(this.personalDetails().includes(_fieldWithError)) {
      this.personalDetailsWrapperTarget.classList.remove("d-none");
      this.businessDetailsWrapperTarget.classList.add("d-none");
    }

    if(this.businessDetails().includes(_fieldWithError)) {
      this.personalDetailsWrapperTarget.classList.add("d-none");
      this.businessDetailsWrapperTarget.classList.remove("d-none");
    }
  }

  showStripeApiError(error, solo = false) {
    // TODO: what about when there's more than one error?
    const fieldWithError = this.possibleFieldsWithErr(error.param).
                             filter((possibleField) => { return this.allDetails().includes(possibleField); });
    const errorAlertElement = document.querySelector(`[data-target='${fieldWithError}-error']`);

    if(solo) { this.togglePersonalBusinessDetails(fieldWithError); }

    if(fieldWithError !== undefined) {
      errorAlertElement.classList.remove("d-none");
      errorAlertElement.textContent = error.message;
    }
  }
}