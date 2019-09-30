import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["clipboardInput", "copiedMessage"]

  highlightInputLink() {
    const linkSelection = window.getSelection();
    const textSelection = document.createRange();

    textSelection.selectNodeContents(this.clipboardInputTarget);
    linkSelection.removeAllRanges();
    linkSelection.addRange(textSelection);
  }

  copyClipboard() {
    this.highlightInputLink();
    document.execCommand("copy");
    this.copiedMessageTarget.classList.add("copied");
    setTimeout(() => this.copiedMessageTarget.classList.remove("copied"), 1000);
  }
}