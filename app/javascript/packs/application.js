/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

// CSS
import "../styles/application.scss";

// JS
import "bootstrap";
import $ from "jquery";
import Rails from "rails-ujs";
import "popper.js";

import "../javascript/custom.js";

window.jQuery = $;
window.$ = $;

Rails.start();

require("dotenv").config();

// Assets
require.context("../images/", true, /\.(gif|jpe?g|png|svg)$/i);
