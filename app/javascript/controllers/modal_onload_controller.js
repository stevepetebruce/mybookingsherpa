import { Controller } from "stimulus"

export default class extends Controller {

  connect() {
    $("#onloadModal").modal("show");
  }
}