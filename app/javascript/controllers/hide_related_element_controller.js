// Hide element when their related element has been clicked.
// Needs this pattern:

// Source element (which is clicked):
// data-action="click->hide-related-element#hideTargetElement"
// data-hide-element="foo"

// Target element (which is hidden):
// data-hide-element-target="foo"

import { Controller } from "stimulus";

export default class extends Controller {
  hideTargetElement() {
    const elementToHideIdentifier = event.target.dataset.hideElement;
    const elementsToHide = document.querySelectorAll(`[data-hide-element-target='${elementToHideIdentifier}']`);

    if (elementsToHide.length > 0) {
      elementsToHide.forEach((elementToHide) => { elementToHide.style.display = "none"; } );
    }
  }
}
