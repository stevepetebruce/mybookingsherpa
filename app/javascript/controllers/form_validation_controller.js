// Bootstrap form validation
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form"]

  checkValidity() {
    if (this.formTarget.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();
    }
    this.formTarget.classList.add("was-validated");
  }
}
