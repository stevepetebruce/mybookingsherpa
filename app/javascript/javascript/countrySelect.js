(async () => {
  const result = await fetch("//freegeoip.app/json/");
  const json = await result.json();
  const selectCountry = document.querySelector("#booking_country");
  if (!selectCountry) return;
  selectCountry.value = json.country_code;
})();