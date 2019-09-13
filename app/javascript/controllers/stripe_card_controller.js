// Handles creating a card token from the data entered into Stripe's form elements.
// Refs: 
// https://stripe.com/docs/api/tokens/create_card
// https://stripe.com/docs/stripe-js/reference#stripe-create-token
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["cardElement", "cardErrors", "form", "submitButton"]

  connect() {
    if (!this.hascardElementTarget) { return; } // handle the in trial pretend form

    const stripe = Stripe(this.data.get("key"));
    const card = this.createCardElement(stripe);
    this.addFormSubmissionHandler(card, stripe);
  }

  addFormSubmissionHandler(card, stripe) {
    this.formTarget.addEventListener("submit", async (event) => {
      event.preventDefault();

      const {token, error} = await stripe.createToken(card);

      this.submitButtonTarget.disabled = false;

      if (error) {
        this.cardErrorsTarget.textContent = error.message;
      } else {
        this.setTokenAndPostFormIfValid(token);
      }

      this.formTarget.classList.add("was-validated");
    });
  }

  addRealTimeValidationHandler(card) {
    card.addEventListener("change", (event) => {
      if (event.error) {
        this.cardErrorsTarget.textContent = event.error.message;
      } else {
        this.cardErrorsTarget.textContent = "";
      }
    });
  }

  createCardElement(stripe) {
    const card = stripe.elements().create("card", { style: this.elementsCustomStyles() });

    card.mount(this.cardElementTarget);
    this.addRealTimeValidationHandler(card);

    return card;
  }

  elementsCustomStyles() {
    return {
      base: {
        color: "#32325d",
        lineHeight: "22px",
        fontFamily: "'Helvetica Neue', Helvetica, sans-serif",
        fontSmoothing: "antialiased",
        fontSize: "17px",
        "::placeholder": {
          color: "#aab7c4"
        }
      },
      invalid: {
        color: "#fa755a",
        iconColor: "#fa755a"
      }
    };
  }

  setTokenAndPostFormIfValid(token) {
    if (this.formTarget.checkValidity() === true) {
      this.stripeTokenHandler(token);
    }
  }


  stripeTokenHandler(token) {
    const hiddenInput = document.createElement("input");

    hiddenInput.setAttribute("type", "hidden");
    hiddenInput.setAttribute("name", "stripeToken");
    hiddenInput.setAttribute("value", token.id);

    this.formTarget.appendChild(hiddenInput);
    this.formTarget.submit();
  }
}
