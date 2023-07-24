function showFileUpload() {
  const addAnotherButton  = document.querySelector('[data-multiupload-element="add-another-file"]');
  const uploadFile  = document.querySelector('[data-multiupload-element="upload-another-file"]');
  // const fileInput = document.querySelector('input[type="file"]')

  if(!addAnotherButton) return;
  if(!uploadFile) return;

  addAnotherButton.style.display = 'none'
  uploadFile.removeAttribute('hidden');
  // if(fileInput) {
  //   setTimeout(fileInput.focus(), 0);
  // }
}

// So we can just access required functions from the window object
window.multiupload = {
  showFileUpload: showFileUpload,
}

// In case we want to require it like a module
module.exports = window.multiupload;
