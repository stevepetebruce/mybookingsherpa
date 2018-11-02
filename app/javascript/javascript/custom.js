// TODO: break this down into more nuanced files and load with webpack
// Keep all Stripe related JS in one file, and only load that file on sensitive pages.
// Eventually we can move most/all JS into Stimulus JS, ref: https://stimulusjs.org/

(function() {
  'use strict';

  const stripe = Stripe('pk_test_mOBtxNpMht2po09RkLReWILl');
  const elements = stripe.elements();

  // Custom styling can be passed to options when creating an Element.
  const style = {
    base: {
      color: '#32325d',
      lineHeight: '24px',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '18px',
      '::placeholder': {
        color: '#aab7c4'
      }
      },
      invalid: {
        color: '#fa755a',
        iconColor: '#fa755a'
      }
  };

  // Create an instance of the card Element.
  const card = elements.create('card', {style});

  // Add an instance of the card Element into the `card-element` <div>.
  card.mount('#card-element');


  card.addEventListener('change', function(event) {
    var displayError = document.getElementById('card-errors');
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = '';
    }
  });

  // Create a token or display an error when the form is submitted.
  const form = document.getElementById('payment-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();

    const {token, error} = await stripe.createToken(card);

    if (error) {
      // Inform the customer that there was an error.
      const errorElement = document.getElementById('card-errors');
      errorElement.textContent = error.message;
    } else {
      console.log(token);
      // Send the token to your server.
      stripeTokenHandler(token);
    }
  });

})();