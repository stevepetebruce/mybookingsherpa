document.addEventListener("DOMContentLoaded", function() {

  const clipboardButtons = document.querySelectorAll('[data-clipboard-btn]');
  const clipboardInputForms = document.querySelectorAll('[data-clipboard-source]');

  function selectText(clipboardInput) {
    if (document.body.createTextRange) {
      const range = document.body.createTextRange();
      range.moveToElementText(clipboardInput);
      range.select();
    } else if (window.getSelection) {
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(clipboardInput);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  }

  function copyToClipboard(e) {
    const clipboardId = e.srcElement.dataset.clipboardBtn;
    const clipboardInput = document.querySelector(`small[data-clipboard-source="${clipboardId}"]`);
    const clipboardMessage = document.querySelector(`span[data-clipboard-message="${clipboardId}"]`);

    if(clipboardInput) {
      selectText(clipboardInput);
      document.execCommand("copy");
      clipboardMessage.classList.add("copied");
      setTimeout(() => clipboardMessage.classList.remove("copied"), 1000);
    }
    e.stopPropagation();
  }

  clipboardButtons.forEach(clipboardButton => clipboardButton.addEventListener("click", copyToClipboard));
  clipboardInputForms.forEach(clipboardInputForm => clipboardInputForm.addEventListener("click", event => event.stopPropagation()));
});