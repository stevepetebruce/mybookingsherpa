(async () => {
  const result = await fetch("//freegeoip.app/json/");
  const json = await result.json();
  document.querySelector("#country").value = json.country_code;
})();