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
  });
}());