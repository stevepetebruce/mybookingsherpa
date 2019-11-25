import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "startDateInput", "endDateInput" ]

  copyDate() {
    if (!this.endDateInputTarget.value) {
      this.endDateInputTarget.value = this.startDateInputTarget.value;
    }
  }
}