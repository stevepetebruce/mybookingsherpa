document.addEventListener("DOMContentLoaded", function() {
  $(".copied").hide();
  window.addEventListener("click", function(e) {
    const clipboardId = e.srcElement.dataset.clipboardBtn;
    const clipboardInput = document.querySelector(`input[data-clipboard-source="${clipboardId}"]`);
    if(clipboardInput) {
      clipboardInput.select();
      document.execCommand("copy");
      $(".copied").show();
      $(".copied").fadeOut(1000);
    }
  });
});