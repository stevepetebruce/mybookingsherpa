document.addEventListener("DOMContentLoaded", function() {

  const tripCurrencySelect = document.querySelector('#trip_currency');
  const costPerGuestPrepend = document.querySelector('#inputGroupPrepend');
  
  if (tripCurrencySelect) {
    tripCurrencySelect.addEventListener("change", function(e) {
      const tripCurrencySelectValue = e.target.value;
      switch(tripCurrencySelectValue) {
        case "eur":
          costPerGuestPrepend.innerHTML = "&euro;"
          break;
        case "gbp":
          costPerGuestPrepend.innerHTML = "&pound;"
          break;
        case "usd":
          costPerGuestPrepend.innerHTML = "&dollar;"
          break;
        default:
          costPerGuestPrepend.innerHTML = "&euro;"
      }
    })
  }
});