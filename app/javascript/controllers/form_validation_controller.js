// Bootstrap form validation
import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["form", "field", "submitButton"]

  addFormFieldsValidationHandlers() {
    this.fieldTargets.forEach((input) => {
      input.addEventListener(("input"), () => {
        if (input.checkValidity()) {
          input.classList.remove("is-invalid");
          input.classList.add("is-valid");
        } else {
          input.classList.remove("is-valid");
          input.classList.add("is-invalid");
        }
        this.enableSubmitButtonIfValid();
      });
    });
  }

  checkValidity() {
    if (this.formTarget.checkValidity() === false) {
      event.preventDefault();
      event.stopPropagation();

      this.addFormFieldsValidationHandlers();
    }
    this.formTarget.classList.add("was-validated");
    this.enableSubmitButtonIfValid();
  }

  enableSubmitButtonIfValid() {
    this.submitButtonTarget.disabled = !this.formTarget.checkValidity();
  }
}
