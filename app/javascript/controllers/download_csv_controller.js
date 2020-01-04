import { Controller } from "stimulus"

export default class extends Controller {
	static targets = ["tableSource", "tableRowSource", "tripSource"]

  getTripDetails() {
    const TripFileName = this.tripSourceTarget.innerHTML.replace(/<\/?span[^>]*>/g," ").split('').map(letter =>letter.trim()).join('');
    this.organiseTrip(this.tableSourceTarget.outerHTML, `${TripFileName}.csv`);
  }

  organiseTrip(html, filename) {
    const csv = [];
    const rows = this.tableRowSourceTargets;

    for (var i = 0; i < rows.length; i++) {
      const row = [];
      const cols = rows[i].querySelectorAll("td, th");

    	for (let j = 0; j < cols.length; j++) 
        row.push(cols[j].innerText);
      csv.push(row.join(","));		
    }

    this.exportSpreadsheet(csv.join("\n"), filename);
  }

  exportSpreadsheet(csv, filename) {
    const csvFile = new Blob([csv], {type: "text/csv"});
    const downloadCsvLink = document.createElement("a");
    downloadCsvLink.download = filename;
    downloadCsvLink.href = window.URL.createObjectURL(csvFile);
    downloadCsvLink.style.display = "none";
    document.body.appendChild(downloadCsvLink);
    downloadCsvLink.click();
  }
}