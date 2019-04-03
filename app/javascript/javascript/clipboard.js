document.addEventListener("DOMContentLoaded", function() {

  const clipboardButtons = document.querySelectorAll('[data-clipboard-btn]');
  
  function copyToClipboard(e) {
    const clipboardId = e.srcElement.dataset.clipboardBtn;
    const clipboardInput = document.querySelector(`input[data-clipboard-source="${clipboardId}"]`);
    console.log(e);
    if(clipboardInput) {
      clipboardInput.select();
      document.execCommand("copy");
    }
    e.stopPropagation();
  }
  clipboardButtons.forEach(clipboardButton => clipboardButton.addEventListener("click", copyToClipboard));
});