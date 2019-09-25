// ref: https://stripe.com/docs/connect/account-tokens#javascript
import { Controller } from "stimulus";

// formDetails - the form that gets sent to Stripe
// formToken - the form (with only the account token in) that gets sent to us
export default class extends Controller {
  static targets = ["percentOwnership"]

  connect() {
  }

  togglePercentOwnership() {
    if (this.percentOwnershipTarget.classList.contains("d-none")) {
      this.percentOwnershipTarget.classList.remove("d-none");
    } else {
      this.percentOwnershipTarget.classList.add("d-none");
    }
  }
}
