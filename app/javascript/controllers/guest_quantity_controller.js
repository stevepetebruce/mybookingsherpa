import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["depositPriceInput", "guestQuantityInput", "outstandingPriceInput", "totalPriceInput"]

  initialize() {
    this.guestCount();
    this.getTotalPrice();
  }

  up(e) {
    e.preventDefault();
    const guestIndex = e.target.getAttribute("data-guest-index");
    const guestInput = this.guestQuantityInputTargets[guestIndex];
    guestInput.value = parseInt(guestInput.value) + 1;
    this.guestCount() 
    if (this.data.get("total") > this.data.get("max")) guestInput.value--; 
    this.getTotalPrice();
  }

  down(e) {
    e.preventDefault();
    const guestIndex = e.target.getAttribute("data-guest-index");
    const guestInput = this.guestQuantityInputTargets[guestIndex];
    guestInput.value = parseInt(guestInput.value) - 1;
    this.guestCount()
    if (guestInput.value <= 0) guestInput.value = 0;
    if (this.guestQuantityInputTargets[0].value < 1) this.guestQuantityInputTargets[0].value = 1;
    this.getTotalPrice();
  }

  guestCount() {
    const count = this.guestQuantityInputTargets.reduce((total, input) => total + parseInt(input.value), 0);
    this.data.set("total", count)
  }

  getTotalPrice() {
    const totalPrice = this.guestQuantityInputTargets.reduce((total, guest) => total + parseInt(guest.value) * guest.dataset.guestPrice, 0);
    const deposit = parseInt(this.data.get("deposit"));
    if (deposit > 0) {
      const depositPrice = Math.ceil(deposit * (totalPrice / 100));
      this.displayDepositPrice(depositPrice, totalPrice);
    } else {
      this.displayFullPrice(totalPrice);
    }
  }

  displayFullPrice(price) {
    this.totalPriceInputTargets.forEach((elem, index) => elem.innerHTML = price)
  }	

  displayDepositPrice(deposit, totalPrice) {
    this.depositPriceInputTargets.forEach((elem, index) => elem.innerHTML = deposit)
    this.totalPriceInputTargets[0].innerHTML = totalPrice;
    this.outstandingPriceInputTarget.innerHTML = totalPrice - deposit;
  }	
}
