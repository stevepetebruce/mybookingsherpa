import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["selectOptionsContainer", "selectWrapper"]

  showBookingOptions() {
    if (event.target.closest("#selectoptions")) return;

    if(event.target === this.selectWrapperTarget && this.selectOptionsContainerTarget.style.display !== "block") {
      this.selectOptionsContainerTarget.style.display = "block";
    } else {
      this.selectOptionsContainerTarget.style.display = "none";
    }  
  }
}