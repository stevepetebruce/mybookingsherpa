import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["tripDescriptionSource", "toggleLinkSource"]

  connect() {
    this.toggleReadMore();
  }

  toggleReadMore() {
    this.toggleLinkSourceTarget.style.visibility = (this.tripDescriptionSourceTarget.innerHTML.length < 120) ? "hidden" : "visible";
  }
}