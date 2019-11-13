import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    if (this.data.has("delay")) {
      setTimeout(function() {
        $("#onloadModal").modal("show");
      }, this.data.get("delay"));
    } else {
      $("#onloadModal").modal("show");
    }

    this.initializeOnHiddenEvent();
  }

  initializeOnHiddenEvent() {
    $("#onloadModal").on("hidden.bs.modal", (e) => {
      if (this.data.has("oncloseRedirectUrl")) {
        window.location.href = this.data.get("oncloseRedirectUrl");
      }
    });
  }
}