import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["source", "symbol"]
  
  switchCurrency() {
    switch(this.sourceTarget.value) {
      case "gbp":
        this.symbolTarget.innerHTML = "&pound;"
        break;
      case "usd":
        this.symbolTarget.innerHTML = "&dollar;"
        break;
      default:
        this.symbolTarget.innerHTML = "&euro;"
    }     
  }
};