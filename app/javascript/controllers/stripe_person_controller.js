// ref: https://stripe.com/docs/connect/account-tokens#javascript
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["addressLine1", "addressLine2", "addressCity",
                    "addressState", "addressPostalCode", "addressCountry",
                    "director", "dob", "email", "firstName", "formDetails",
                    "formToken", "formTokenFirstName", "formTokenLastName",
                    "lastName", "owner", "percentOwnership",
                    "percentOwnershipValue", "submitBtn",
                    "submitBtnAddAnother", "titleAddress", 
                    "titlePersonalDetails", "tokenPerson"]

  connect() {
    this.handleFormSubmission();
  }

  handleFormSubmission() {
    const stripe = Stripe(this.data.get("key"));

    this.formDetailsTarget.addEventListener("submit", async (event) => {
      event.preventDefault();

      const personResult = await stripe.createToken("person", {
          person: {
            first_name: this.firstNameTarget.value,
            last_name: this.lastNameTarget.value,
            email: this.emailTarget.value,
            address: {
              line1: this.addressLine1Target.value,
              line2: this.addressLine2Target.value,
              city: this.addressCityTarget.value,
              state: this.addressStateTarget.value,
              postal_code: this.addressPostalCodeTarget.value,
              country: this.addressCountryTarget.value
            },
            dob: {
              day: this.dobTarget.value.split("-")[2],
              month: this.dobTarget.value.split("-")[1],
              year: this.dobTarget.value.split("-")[0]
            },
            relationship: {
              director: this.directorTarget.checked,
              owner: this.ownerTarget.checked,
              percent_ownership: parseInt(this.percentOwnershipValueTarget.value),
            }
          }
        }
      );

      if (personResult.token) {
        this.tokenPersonTarget.setAttribute("value", personResult.token.id);
        this.formTokenFirstNameTarget.setAttribute("value", this.firstNameTarget.value);
        this.formTokenLastNameTarget.setAttribute("value", this.lastNameTarget.value);

        this.formTokenTarget.submit();
      }

      if (personResult.error) {
        // TODO: handle errors
      }
    });
  }

  // TODO: this is overloaded now - it's not just toggling PercentOwnership
  // Need to rename
  togglePercentOwnership() {
    if (this.percentOwnershipTarget.classList.contains("d-none")) {
      this.percentOwnershipTarget.classList.remove("d-none");
      this.titleAddressTarget.innerHTML = "Owner's Address";
      this.titlePersonalDetailsTarget.innerHTML = "Owner's personal details";
    } else {
      this.percentOwnershipTarget.classList.add("d-none");
      this.titleAddressTarget.innerHTML = "Director's Address";
      this.titlePersonalDetailsTarget.innerHTML = "Director's personal details";
    }
  }
}
