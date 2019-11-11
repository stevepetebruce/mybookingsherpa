import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    $("#onloadModal").modal("show");
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