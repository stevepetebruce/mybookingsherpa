// Handles creating a payment intent from the data entered into Stripe's form elements.
// Refs: 
// https://stripe.com/docs/payments/cards/saving-cards-after-payment
// https://stripe.com/docs/stripe-js/reference#stripe-handle-card-payment
import { Controller } from "stimulus";

// TODO: could possibly extend the form_validation_controller... as we're duplicating alot of it here
export default class extends Controller {
  static targets = ["cardElement", "cardErrors", "field", "form", "submitButton"]

  connect() {
    if (!this.hasCardElementTarget) { return; } // handle the in trial pretend form

    const stripe = Stripe(this.data.get("key"), {
      stripeAccount: this.data.get("connectedAccountId")
    });
    const card = this.createCardElement(stripe);
    this.addFormSubmissionHandler(card, stripe);
  }

  addFormSubmissionHandler(card, stripe) {
    this.formTarget.addEventListener("submit", async (event) => {
      event.preventDefault();
      this.submitButtonTarget.disabled = true;

      if (this.formTarget.checkValidity() === true) {
        const {paymentIntent, error} = await stripe.handleCardPayment(
        this.data.get("secret"), card);

        if (error) {
          this.cardErrorsTarget.textContent = error.message;
          this.submitButtonTarget.disabled = false;
        } else if (paymentIntent.requires_action) {
          this.authenticationRequired(paymentIntent);
        } else {
          this.handlePaymentMethod(paymentIntent.payment_method);
        }
      } else {
        this.formTarget.classList.add("was-validated");
        this.submitButtonTarget.disabled = false;
        this.addFormFieldsValidationHandlers();
      }
    });
  }

  addFormFieldsValidationHandlers() {
    this.fieldTargets.forEach((input) => {
      input.addEventListener(("input"), () => {
        if (input.checkValidity()) {
          input.classList.remove("is-invalid")
          input.classList.add("is-valid");
        } else {
          input.classList.remove("is-valid")
          input.classList.add("is-invalid");
        }
        this.enableSubmitButtonIfValid();
      });
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

  authenticationRequired(paymentIntent) {
    stripe.handleCardAction(paymentIntent.payment_intent_client_secret)
    .then(function(result) {
      if (result.error) {
        this.cardErrorsTarget.textContent = result.error.message;
      } else {
        this.cardErrorsTarget.textContent = "";
        this.handlePaymentMethod(paymentIntent.payment_method);
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

  enableSubmitButtonIfValid() {
    this.submitButtonTarget.disabled = !this.formTarget.checkValidity();
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