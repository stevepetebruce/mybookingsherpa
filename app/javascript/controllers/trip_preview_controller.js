import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ["datePreview", "depositPreview", "depositRemainderPreview", "depositPreviewContainer",
                    "depositDatePreview", "depositWrapper", "descriptionInput", "descriptionPreview",
                    "depositPercentageInput", "endDateInput", "form", "fullCostInput", "fullCostPreview",
                    "nameInput", "namePreview", "paymentWindowWeeksInput", "startDateInput"]

  connect() {
    this.previewUpdate();
    this.formTarget.addEventListener("submit", () => {
      this.scrollToTopIfInvalid();
    });
  }
  
  previewUpdate() {
    // Trip Dates
    const startDate = this.startDateInputTarget.value.slice(-2);
    const endDate = this.endDateInputTarget.value.slice(-2);
    const startMonth = new Date(this.startDateInputTarget.value).toLocaleString('default', { month: 'long' });
    const endMonth = new Date(this.endDateInputTarget.value).toLocaleString('default', { month: 'long' });

    if (!this.startDateInputTarget.value || !this.endDateInputTarget.value) {
      this.datePreviewTarget.innerHTML = "Dates displayed here";
    } else if (this.startDateInputTarget.value !== this.endDateInputTarget.value) {
      if (startMonth === endMonth) {
        this.datePreviewTarget.innerHTML = `${startDate} - ${endDate} ${endMonth}`;
      } else {
        this.datePreviewTarget.innerHTML = `${startDate} ${startMonth} - ${endDate} ${endMonth}`;
      }
    } else {
      this.datePreviewTarget.innerHTML = `${startDate} ${startMonth}`;
    }

    this.namePreviewTarget.innerHTML = this.nameInputTarget.value || "Trip Name";
    this.descriptionPreviewTarget.innerHTML = this.descriptionInputTarget.value || "Trip description will be displayed here...";

    this.fullCostPreviewTargets.map((target, index) => {
      this.fullCostPreviewTargets[index].innerHTML = this.fullCostInputTarget.value || "💰💰💰";
    });

    if (this.depositPercentageInputTarget.value) {
      this.depositWrapperTarget.style.display = "block";
    } else {
      this.depositWrapperTarget.style.display = "none";
    }

    this.depositPreviewTarget.innerHTML = ((this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value).toFixed(2);
    this.depositRemainderPreviewTarget.innerHTML = this.fullCostInputTarget.value - ((this.fullCostInputTarget.value/100)*this.depositPercentageInputTarget.value).toFixed(2);

    // Full payment Date
    if (this.startDateInputTarget.value) {
      const tripDate = new Date(this.startDateInputTarget.value);
      const paymentDate = new Date(tripDate);
      paymentDate.setDate(tripDate.getDate() - this.paymentWindowWeeksInputTarget.value * 7);
      this.depositDatePreviewTarget.innerHTML = paymentDate.toISOString().split('T')[0].split("-").reverse().join("-");
    }
  }

  scrollToTopIfInvalid() {
    if (this.formTarget.checkValidity() === false) {
      document.getElementsByClassName("container")[0].scrollIntoView({behavior: "smooth"});
    }
  }
}