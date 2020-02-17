import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "pointerBannerSource", "pointerIndexSource" ]

  connect() {
    if (this.hasPointerBannerSourceTarget) {
      this.pointerIndexSourceTargets.map(pointer => pointer.remove())
    }
  }
}