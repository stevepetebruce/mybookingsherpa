import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["tripDescriptionSource", "toggleLinkSource"]

  connect() {
    this.toggleReadMore();
  }

  toggleReadMore() {
    this.toggleLinkSourceTarget.style.display = (this.tripDescriptionSourceTarget.innerHTML.length < 160) ? "none" : "inline";
  }
}