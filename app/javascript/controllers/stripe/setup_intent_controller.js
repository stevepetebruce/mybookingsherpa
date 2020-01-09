// Handles creating a setup_intent and payment_method from the data entered into Stripe's form elements.
// Refs:
// https://stripe.com/docs/payments/setup-intents
// https://stripe.com/docs/api/setup_intents/object#setup_intent_object-client_secret
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["cardElement", "cardErrors", "form", "submitButton"]

  connect() {
    if (!this.hasCardElementTarget) { return; } // handle the in trial pretend form

    const stripe = Stripe(this.data.get("key"));
    const card = this.createCardElement(stripe);
    this.addFormSubmissionHandler(card, stripe);
  }

  addFormSubmissionHandler(card, stripe) {
    this.formTarget.addEventListener("submit", async (event) => {
      event.preventDefault();
      this.submitButtonTarget.disabled = true;

      const {setupIntent, error} = await stripe.confirmCardSetup(
        this.data.get("secret"),
        {
          payment_method: {
            card: card
          }
        });

      if (error) {
        this.cardErrorsTarget.textContent = error.message;
        this.submitButtonTarget.disabled = false;
      } else if (setupIntent.requires_action) {
        this.authenticationRequired(setupIntent);
      } else {
        this.handlePaymentMethod();
      }
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

  authenticationRequired(setupIntent) {
    stripe.handleCardAction(setupIntent.client_secret)
    .then(function(result) {
      if (result.error) {
        this.cardErrorsTarget.textContent = result.error.message;
      } else {
        this.cardErrorsTarget.textContent = "";
        this.handlePaymentMethod();
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

  handlePaymentMethod() {
    if (this.formTarget.checkValidity() === true) {
      this.formTarget.submit();
    }
  }
}
