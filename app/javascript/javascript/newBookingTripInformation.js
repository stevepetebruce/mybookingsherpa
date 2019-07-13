document.addEventListener("DOMContentLoaded", function() {
  const tripDescription = document.querySelector("#collapseSummary");
  if (!tripDescription) return;
  const expandMinDescriptionLength = 160;
  const descriptionLength = tripDescription.innerHTML.length;
  const readMoreToggleLink = document.querySelector("a[data-toggle='collapse']");

  if (descriptionLength < expandMinDescriptionLength) readMoreToggleLink.style.display = "none";
});