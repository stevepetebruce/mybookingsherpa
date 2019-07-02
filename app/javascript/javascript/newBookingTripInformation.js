document.addEventListener("DOMContentLoaded", function() {
  const tripDescription = document.querySelector("#collapseSummary");
  const expandMinDescriptionLength = 160;
  const descriptionLength = tripDescription.innerHTML.length;
  const readMoreToggleLink = document.querySelector("a[data-toggle='collapse']");

  if (!tripDescription) return;

  if (descriptionLength < expandMinDescriptionLength) readMoreToggleLink.style.display = "none";
});