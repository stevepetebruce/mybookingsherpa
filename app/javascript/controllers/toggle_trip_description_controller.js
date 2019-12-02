import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["tripDescriptionSource", "toggleLinkSource"]

  connect() {
    if (this.tripDescriptionSourceTarget.innerHTML.length < 160) this.toggleLinkSourceTarget.style.display = "none";
  }
}