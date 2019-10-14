import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["source", "symbol"]
  
  switchCurrency() {
    this.symbolTargets.map((target, index) => {
      switch(this.sourceTarget.value) {
        case "gbp":
          this.symbolTargets[index].innerHTML = "&pound;"
          break;
        case "usd":
          this.symbolTargets[index].innerHTML = "&dollar;"
          break;
        default:
          this.symbolTargets[index].innerHTML = "&euro;"
      }     
    });
  }
};