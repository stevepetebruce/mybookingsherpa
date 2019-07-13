(async () => {
  const selectCountry = document.querySelector("#booking_country");
  if (!selectCountry) return;
  // current country
  const countryResult = await fetch("//freegeoip.app/json/");
  const countryJson = await countryResult.json();
  // International country code
  const phoneResult = await fetch(`https://restcountries.eu/rest/v2/alpha/${countryJson.country_code}`);
  const phoneJson = await phoneResult.json();

  selectCountry.value = countryJson.country_code;

  const selectPhone = document.querySelector("#booking_phone_number");
  const selectNextKinPhone = document.querySelector("#booking_next_of_kin_phone_number");
  if (!selectPhone || !selectNextKinPhone) return;
  let intPhoneCode = `+${phoneJson.callingCodes[0]}`;
  [selectPhone.value, selectNextKinPhone.value] = [intPhoneCode, intPhoneCode];
})();