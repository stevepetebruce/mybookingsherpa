import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "startDateInput", "endDateInput" ]

  copyDate() {
    this.endDateInputTarget.value = this.startDateInputTarget.value
  }
}