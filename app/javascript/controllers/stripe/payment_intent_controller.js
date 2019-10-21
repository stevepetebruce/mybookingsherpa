// Handles creating a payment intent from the data entered into Stripe's form elements.
// Refs: 
// https://stripe.com/docs/payments/cards/saving-cards-after-payment
// https://stripe.com/docs/stripe-js/reference#stripe-handle-card-payment
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

      const {paymentIntent, error} = await stripe.handleCardPayment(
        this.data.get("secret"), card);

      if (error) {
        this.cardErrorsTarget.textContent = event.error.message;
        this.submitButtonTarget.disabled = false;
      } else if (paymentIntent.requires_action) {
        stripe.handleCardAction(paymentIntent.payment_intent_client_secret)
        .then(function(result) {
          if (result.error) {
            // Show error in payment form
          } else {
            // The card action has been handled
            // The PaymentIntent can be confirmed again on the server
            this.handlePaymentMethod(paymentIntent.payment_method);
          }
        });
      } else {
        this.handlePaymentMethod(paymentIntent.payment_method);
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

  handlePaymentMethod(paymentMethod) {
    if (this.formTarget.checkValidity() === true) {
      const hiddenInput = document.createElement("input");

      hiddenInput.setAttribute("type", "hidden");
      hiddenInput.setAttribute("name", "stripePaymentMethod");
      hiddenInput.setAttribute("value", paymentMethod);

      this.formTarget.appendChild(hiddenInput);
      this.formTarget.submit();
    }
  }
}