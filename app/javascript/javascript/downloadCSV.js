document.addEventListener("DOMContentLoaded", function() {

  const downloadCsv = function(csv, filename) {
    var csvFile;
    var downloadCsvLink;

    // CSV file
    csvFile = new Blob([csv], {type: "text/csv"});
    // Hidden CSV link
    downloadCsvLink = document.createElement("a");
    downloadCsvLink.download = filename;
    downloadCsvLink.href = window.URL.createObjectURL(csvFile);
    downloadCsvLink.style.display = "none";
    document.body.appendChild(downloadCsvLink);
    downloadCsvLink.click();
  }

  const exportTableToCsv = function(html, filename) {
  	const csv = [];
  	const rows = document.querySelectorAll("table tr");
      for (var i = 0; i < rows.length; i++) {
  		const row = [], cols = rows[i].querySelectorAll("td, th");
        for (var j = 0; j < cols.length; j++) 
          row.push(cols[j].innerText);
  		csv.push(row.join(","));		
  	}
    downloadCsv(csv.join("\n"), filename);
  }

  const downloadCsvButton = document.querySelector("[data-csvButton]");

  if (!downloadCsvButton) {
    return;
  } else {
    // get trip name and remove span and spacing
    let TripName = document.querySelector("h1").innerHTML;
    TripName = TripName.replace(/<\/?span[^>]*>/g," ").split('').map(letter =>letter.trim()).join('');

    downloadCsvButton.addEventListener("click", function () {
      const html = document.querySelector("table").outerHTML;
    	exportTableToCsv(html, `${TripName}.csv`);
    });
  };

});