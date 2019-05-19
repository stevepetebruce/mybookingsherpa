document.addEventListener("DOMContentLoaded", function() {

  const editTrip = document.querySelector("[data-edit-trip]");
  const addTrip = document.querySelector("[data-add-trip]");
  const editLinks = Array.from(document.querySelectorAll("[data-edit-link]"));

  const displayEdits = function (e){
    editLinks.map(editLink => {
      editLink.classList.toggle("hide-edit");
    });
  }

  function stopPropagation(e) {
    e.stopPropagation();
  }

  function addTripRoute() {
    location.href='/guides/trips/new'
  }

  editLinks.forEach(editLink => editLink.addEventListener("click", stopPropagation));

  if(editTrip) {editTrip.addEventListener("click", displayEdits)}

  if(addTrip) {addTrip.addEventListener("click", addTripRoute)};
  
});