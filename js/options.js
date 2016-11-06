
//intital Elm app
var app = Elm.Spelling.fullscreen();

//start firebase and stuff
var config = {
  apiKey: "AIzaSyAx8DzcZ8tkfQbW-J5JNHEnC56nkH2BBAQ",
  authDomain: "bouzer-8e042.firebaseapp.com",
  databaseURL: "https://bouzer-8e042.firebaseio.com",
  storageBucket: "bouzer-8e042.appspot.com",
  messagingSenderId: "163879527939"
};
firebase.initializeApp(config);

var db = firebase.database();
var ref = db.ref("root/");
var tabsRef = ref.child("tabs");

function handleUpdated(tabId, changeInfo, tabInfo) {
  // console.log("Updated tab: " + tabId);
  // console.log("Changed attributes: ");
  // console.log(changeInfo);
  // console.log("New tab Info: ");
  // console.log(tabInfo);

  chrome.tabs.query({
      currentWindow: true
    }, function(data) {
      updateState(data);
    });
}

chrome.tabs.onUpdated.addListener(handleUpdated);
chrome.tabs.onRemoved.addListener(handleUpdated);
chrome.tabs.onCreated.addListener(handleUpdated);

app.ports.close.subscribe(function(tab) {
    // close tab here
    // console.log(tab);
    chrome.tabs.remove(tab, function() { });

    // send back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});


app.ports.activate.subscribe(function(tab) {
    // make tab active here
    // console.log(tab);
    chrome.tabs.update(tab,  {selected: true} );

    // send back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});


//Send query and to chrome, ask for tabs and send it to elm
chrome.tabs.query({
    currentWindow: true
  }, function(data) {
    updateState(data);
  });


// main update function which sends data to elm and firebase
function updateState(data) {
  var tabsElm = [];
  return data.map(function(tab){
    // console.log(tab);
    tabz = {
      'url' : tab.url,
      'title' : tab.title,
      'index' : tab.index,
      'active': tab.active,
      'tabID' : tab.id,
      'favIconUrl' : tab.favIconUrl ? tab.favIconUrl : '../../icons/icon48.png'
    };
    tabsElm.push(tabz);
    return tabsElm;
  }),
  tabsRef.set(tabsElm),
  app.ports.initialTabs.send(tabsElm);
}
