document.addEventListener("DOMContentLoaded", function() {

  const clipboardButtons = document.querySelectorAll('[data-clipboard-btn]');
  const clipboardInputForms = document.querySelectorAll('[data-clipboard-source]');
  
  function copyToClipboard(e) {
    const clipboardId = e.srcElement.dataset.clipboardBtn;
    const clipboardInput = document.querySelector(`input[data-clipboard-source="${clipboardId}"]`);
    if(clipboardInput) {
      clipboardInput.select();
      document.execCommand("copy");
    }
    e.stopPropagation();
  }
  clipboardButtons.forEach(clipboardButton => clipboardButton.addEventListener("click", copyToClipboard));
  clipboardInputForms.forEach(clipboardInputForm => clipboardInputForm.addEventListener("click", event => event.stopPropagation()));
});