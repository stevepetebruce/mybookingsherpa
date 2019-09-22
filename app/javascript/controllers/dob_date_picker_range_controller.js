import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["dateSource"]
  
  connect() {
    const day = ('0' + new Date().getDate()).slice(-2);
    const month = ('0' + (new Date().getMonth() + 1)).slice(-2);
    const year = new Date().getFullYear();
    const maxYear = year - 18;
    
    this.dateSourceTarget.setAttribute("max", `${maxYear}-${month}-${day}`);
  }
};