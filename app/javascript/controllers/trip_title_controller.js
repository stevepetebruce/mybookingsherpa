import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["tripNameSource"]
  
  connect() {
    this.tripNameSourceTarget.innerHTML = this.tripNameSourceTarget.innerHTML.split("").map((letter, i) => {
      return((letter === "-") ? `-<br>` : `${letter}`);
    }).join("");
  }
}