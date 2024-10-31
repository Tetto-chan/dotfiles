chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {

   if (request.message === 'TabUpdated') {



      console.log('URL Updated:', request.text);
      // Add your logic here for handling the URL change
   }
});
