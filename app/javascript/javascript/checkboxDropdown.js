document.addEventListener("DOMContentLoaded", function() {
  let expanded = false;
  const showCheckboxes = function(e) {
    const options = document.querySelector("#selectoptions");

    if (e.target.closest("#selectoptions")) return;

    if(e.target.matches(".selectwrapper") && !expanded) {
      options.style.display = "block";
      expanded = true;
    } else {
      options.style.display = "none";
      expanded = false;
    } 
  }
  const editBookingContainer = document.querySelector("[data-container='edit-booking']");
  editBookingContainer.addEventListener("click", showCheckboxes);
});