// TODO: break this down into more nuanced files and load with webpack
// Keep all Stripe related JS in one file, and only load that file on sensitive pages.
// Eventually we can move most/all JS into Stimulus JS, ref: https://stimulusjs.org/

(function() {
  "use strict";

  document.addEventListener("DOMContentLoaded", function(){

    // Bootstrap form validation
    const forms = document.getElementsByClassName("needs-validation");
    // Loop over them and prevent submission
    Array.prototype.filter.call(forms, function(form) {
      form.addEventListener("submit", function(event) {
        if (form.checkValidity() === false) {
          event.preventDefault();
          event.stopPropagation();
        }
        form.classList.add("was-validated");
        document.querySelectorAll("input[type='submit']")[0].disabled = false;
      }, false);
    });

    // Stripe JS:
    const stripe = Stripe(process.env.STRIPE_PUBLISHABLE_KEY);
    const elements = stripe.elements();
    const stripeTokenHandler = (token) => {
      // Insert the token ID into the form so it gets submitted to the server
      const form = document.getElementById("payment-form");
      const hiddenInput = document.createElement("input");
      hiddenInput.setAttribute("type", "hidden");
      hiddenInput.setAttribute("name", "stripeToken");
      hiddenInput.setAttribute("value", token.id);
      form.appendChild(hiddenInput);

      // Submit the form
      form.submit();
    };

    // Custom styling can be passed to options when creating an Element.
    const style = {
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

    // Create an instance of the card Element.
    const card = elements.create("card", {style});

    // Add an instance of the card Element into the `card-element` <div>.
    if (document.getElementById("card-element") !== null) {
      card.mount("#card-element");

      card.addEventListener("change", function(event) {
        var displayError = document.getElementById("card-errors");
        if (event.error) {
          displayError.textContent = event.error.message;
        } else {
          displayError.textContent = "";
        }
      });

      // Create a token or display an error when the form is submitted.
      const form = document.getElementById("payment-form");
      form.addEventListener("submit", async (event) => {
        event.preventDefault();

        const {token, error} = await stripe.createToken(card);

        if (error) {
          // Inform the customer that there was an error.
          const errorElement = document.getElementById("card-errors");
          errorElement.textContent = error.message;
        } else {
          // Send the token to your server.
          if (form.checkValidity() === true) {
            stripeTokenHandler(token);
          }
          form.classList.add("was-validated");
        }
        document.querySelectorAll("input[type='submit']")[0].disabled = false;
      });
    }
  });
}());