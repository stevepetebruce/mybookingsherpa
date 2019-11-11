import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["clipboardHiddenInput", "clipboardInput", "copiedMessage"]

  highlightInputLink() {
    const linkSelection = window.getSelection();
    const textSelection = document.createRange();

    textSelection.selectNodeContents(this.clipboardInputTarget);
    linkSelection.removeAllRanges();
    linkSelection.addRange(textSelection);
  }

  selectHiddenLink() {
    const linkSelection = window.getSelection();
    const textSelection = document.createRange();

    textSelection.selectNodeContents(this.clipboardHiddenInputTarget);
    linkSelection.removeAllRanges();
    linkSelection.addRange(textSelection);
  }

  copyClipboard() {
    this.selectHiddenLink();
    document.execCommand("copy");

    this.highlightInputLink();

    this.copiedMessageTarget.classList.add("copied");
    setTimeout(() => this.copiedMessageTarget.classList.remove("copied"), 1000);
  }
}