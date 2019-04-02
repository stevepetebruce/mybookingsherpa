(async () => {
  const result = await fetch("//freegeoip.app/json/");
  const json = await result.json();
  document.querySelector("#booking_country").value = json.country_code;
})();