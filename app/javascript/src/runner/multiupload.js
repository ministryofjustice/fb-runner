function showFileUpload() {
  const addAnotherButton  = document.querySelector('[data-multiupload-element="add-another-file"]');
  const uploadFile  = document.querySelector('[data-multiupload-element="upload-another-file"]');

  if(!addAnotherButton) return;
  if(!uploadFile) return;

  // addAnotherButton.setAttribute('hidden', '');
  addAnotherButton.style.display = 'none'
  uploadFile.removeAttribute('hidden');
}

// function upload() {

// }

// So we can just access required functions from the window object
window.multiupload = {
  showFileUpload: showFileUpload,
}

// In case we want to require it like a module
module.exports = window.multiupload;
