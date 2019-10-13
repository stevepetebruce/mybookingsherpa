import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [  "currencyInput", "currencyPreview", "datePreview", "depositPreview", "depositRemainderPreview", 
                      "depositPreviewContainer", "depositDatePreview", "descriptionInput", "descriptionPreview", 
                      "depositPercentageInput", "endDateInput", "fullCostInput", "fullCostPreview", 
                      "nameInput", "namePreview", "paymentWindowWeeksInput", "startDateInput" 
                    ]
  
  previewUpdate() {
    // Trip Dates
    const startDate = this.startDateInputTarget.value.slice(-2);
    const endDate = this.endDateInputTarget.value.slice(-2);
    const startMonth = new Date(this.startDateInputTarget.value).toLocaleString('default', { month: 'long' });
    const endMonth = new Date(this.endDateInputTarget.value).toLocaleString('default', { month: 'long' });

    if (!this.startDateInputTarget.value || !this.endDateInputTarget.value) {
      this.datePreviewTarget.innerHTML = "Dates displayed here";
    } else {
      if (startMonth == endMonth) {
        this.datePreviewTarget.innerHTML = `${startDate} - ${endDate} ${endMonth}`;
      } else {
        this.datePreviewTarget.innerHTML = `${startDate} ${startMonth} - ${endDate} ${endMonth}`;
      }
    }

    this.namePreviewTarget.innerHTML = this.nameInputTarget.value || "Trip Title";
    this.descriptionPreviewTarget.innerHTML = this.descriptionInputTarget.value || "Description is displayed here...";

    this.fullCostPreviewTargets.map((target, index) => {
      console.log(target, index);
      this.fullCostPreviewTargets[index].innerHTML = this.fullCostInputTarget.value || "100";
    });

    this.depositPreviewTarget.innerHTML = ((this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value).toFixed(2);
    this.depositRemainderPreviewTarget.innerHTML = this.fullCostInputTarget.value - ((this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value).toFixed(2);

    this.currencyPreviewTargets.map((target, index) => {
      switch(this.currencyInputTarget.value) {
        case "gbp":
          this.currencyPreviewTargets[index].innerHTML = "&pound;"
          break;
        case "usd":
          this.currencyPreviewTargets[index].innerHTML = "&dollar;"
          break;
        default:
          this.currencyPreviewTargets[index].innerHTML = "&euro;"
      }     
    });
    
    // Full payment Date
    const tripDate = new Date(this.startDateInputTarget.value);
    const paymentDate = new Date(tripDate);
    paymentDate.setDate(tripDate.getDate() - this.paymentWindowWeeksInputTarget.value * 7);
    this.depositDatePreviewTarget.innerHTML = paymentDate.toISOString().split('T')[0];
  }
};
