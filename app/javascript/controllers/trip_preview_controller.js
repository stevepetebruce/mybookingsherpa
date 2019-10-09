import { Controller } from "stimulus"

export default class extends Controller {
  static targets = [ "nameInput", "namePreview", "startDateInput", "endDateInput", "datePreview",
                      "descriptionInput", "descriptionPreview", "fullCostInput", "fullCostPreview",
                      "depositPercentageInput", "paymentWindowWeeksInput", "depositPreview", "depositRemainderPreview",
                      "depositPreviewContainer", "depositDatePreview"
                     ]
  
  previewUpdate() {
    const startDate = this.startDateInputTarget.value.slice(-2);
    const endDate = this.endDateInputTarget.value.slice(-2);
    const startMonth = new Date(this.startDateInputTarget.value).toLocaleString('default', { month: 'long' });
    const endMonth = new Date(this.endDateInputTarget.value).toLocaleString('default', { month: 'long' });

    if (startMonth == endMonth) {
      this.datePreviewTarget.innerHTML = `${startDate} - ${endDate} ${endMonth}`;
    } else {
      this.datePreviewTarget.innerHTML = `${startDate} ${startMonth} - ${endDate} ${endMonth}`;
    }

    this.namePreviewTarget.innerHTML = this.nameInputTarget.value;
    this.descriptionPreviewTarget.innerHTML = this.descriptionInputTarget.value;
    this.fullCostPreviewTarget.innerHTML = this.fullCostInputTarget.value;
    this.depositPreviewTarget.innerHTML = (this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value;
    this.depositRemainderPreviewTarget.innerHTML = this.fullCostInputTarget.value - ((this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value);
    

    const origDate = new Date(this.startDateInputTarget.value);
    console.log(origDate);
    console.log(this.paymentWindowWeeksInputTarget.value);
    this.depositDatePreviewTarget.innerHTML = origDate.setDate(origDate.getDate() - (this.paymentWindowWeeksInputTarget.value * 7));
  }
};
