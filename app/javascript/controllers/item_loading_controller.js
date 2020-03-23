import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "loadingButton" ]

  loadingIcon() {
  	this.loadingButtonTarget.innerHTML = "<div class='loader'>Loading...</div>";
  }
}

