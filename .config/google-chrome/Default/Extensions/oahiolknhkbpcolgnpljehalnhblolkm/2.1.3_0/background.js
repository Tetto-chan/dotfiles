try {
  chrome.tabs.onUpdated.addListener(function (tabId, changeInfo, tab) {
    if (changeInfo.status === 'complete') {
      chrome.tabs.sendMessage(tabId, {
        message: 'TabUpdated'
      });
    }
  });

  chrome.runtime.onInstalled.addListener(details => {
    if (details.reason == "install") {
      let externalUrl = "https://ravensmove.com/shortsblocker-donation/";
      chrome.tabs.create({ url: externalUrl }, (tab) => {
        console.debug("[ShortsBlocker Debug]: Ask for donation.");
      });
    }
  });
} catch(e) {
  console.log("Error from 'Remove Youtube Shorts': ", e)
}
