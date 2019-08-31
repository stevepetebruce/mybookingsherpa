// Automatically selects the country in the country_select field using: 
//   https://freegeoip.app/json/
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["countrySelectField", "phoneField"]

  connect() {
    this.setGeoFields();
  }

  async setGeoFields() {
    const geoData = await fetch("//freegeoip.app/json/");
    const geoDataJson = await geoData.json();

    const phoneData = await fetch(`https://restcountries.eu/rest/v2/alpha/${geoDataJson.country_code}`);
    const phoneDataJson = await phoneData.json();

    this.countrySelectFieldTargets.forEach(function(countrySelectField) {
      countrySelectField.value = geoDataJson.country_code;
    });

    this.phoneFieldTargets.forEach(function(phoneField) {
      phoneField.value = `+${phoneDataJson.callingCodes[0]}`;
    });
  }
}
