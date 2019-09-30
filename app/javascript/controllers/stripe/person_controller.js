// ref: https://stripe.com/docs/connect/account-tokens#javascript
import { StripeBaseController } from "./base_controller";

export default class extends StripeBaseController {
  static targets = ["addAnotherPerson", "addressLine1", "addressLine2",
                    "addressCity", "addressState", "addressPostalCode",
                    "addressCountry", "director", "dob", "email", "firstName",
                    "formDetails", "formToken", "formTokenAddAnotherCompanyPerson",
                    "formTokenFirstName", "formTokenLastName", "lastName",
                    "owner", "percentOwnership", "percentOwnershipValue",
                    "required", "submitBtn", "submitBtnAddAnother",
                    "titleAddress", "titlePersonalDetails", "tokenAccount",
                    "tokenPerson"]

  accountObject() {
    return {
      business_type: "company",
      company: {
        directors_provided: true,
        owners_provided: true
      }
    };
  }

  addAnotherPerson() {
    event.preventDefault();
    this.handleFormSubmission(true);
  }

  addPerson() {
    event.preventDefault();
    this.handleFormSubmission(false);
  }

  allRequiredFieldsComplete() {
    return this.requiredTargets.
      every((requiredField) => requiredField.value.length !== 0);
  }

  async createAccountToken(stripe) {
    return stripe.createToken("account", this.accountObject());
  }

  async createPersonToken(stripe) {
    return stripe.createToken("person", this.personObject());
  }

  enableSubmitBtns() {
    this.submitBtnTarget.disabled = false;
    this.submitBtnAddAnotherTarget.disabled = false;
  }

  handleFormSubmission(addAnotherPerson) {
    if(this.allRequiredFieldsComplete()) {
      this.requestStripeTokenAndSubmitForm(addAnotherPerson);
    } else {
      this.showEmptyFieldsErrors();
    }
  }

  personObject() {
    return {
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
    };
  }

  async requestStripeTokenAndSubmitForm(addAnotherPerson) {
    const stripe = Stripe(this.data.get("key"));
    let accountResult, accountToken, personResult;

    if(addAnotherPerson) {
      accountToken = { id: null };
      accountResult = { error: false, token: { id: null } };
      personResult = await stripe.createToken("person", this.personObject());
    } else { // Finished adding people
      [accountResult, personResult] = await Promise.all([this.createAccountToken(stripe), this.createPersonToken(stripe)]);
    }

    if (personResult.error) {
      this.showStripeApiError(personResult.error);
    } else if(accountResult.error) {
      this.showStripeApiError(accountResult.error);
    } else {
      this.submitTokenForm(personResult.token.id, accountResult.token.id, addAnotherPerson);
    }
  }

  submitTokenForm(personTokenId, accountTokenId, addAnotherPerson) {
    this.formTokenAddAnotherCompanyPersonTarget.setAttribute("value", addAnotherPerson);
    this.tokenAccountTarget.setAttribute("value", accountTokenId);
    this.tokenPersonTarget.setAttribute("value", personTokenId);
    this.formTokenFirstNameTarget.setAttribute("value", this.firstNameTarget.value);
    this.formTokenLastNameTarget.setAttribute("value", this.lastNameTarget.value);

    this.formTokenTarget.submit();
  }

  showEmptyFieldsErrors() {
    this.requiredTargets.forEach(this.toggleEmptyFieldErrMsg);
  }

  toggleCompanyRelationship() {
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

  toggleEmptyFieldErrMsg(target) {
    if (target.value.length === 0) {
      target.nextElementSibling.classList.remove("d-none");
    } else {
      target.nextElementSibling.classList.add("d-none");
    }
  }
}
