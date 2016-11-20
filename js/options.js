
//intital Elm app
const app = Elm.Spelling.fullscreen();

//start firebase and stuff
const config = {
  apiKey: "AIzaSyAx8DzcZ8tkfQbW-J5JNHEnC56nkH2BBAQ",
  authDomain: "bouzer-8e042.firebaseapp.com",
  databaseURL: "https://bouzer-8e042.firebaseio.com",
  storageBucket: "bouzer-8e042.appspot.com",
  messagingSenderId: "163879527939"
};
firebase.initializeApp(config);

const db = firebase.database();
const ref = db.ref("root/");
const currentTabsRef = ref.child("currentTabs");
const savedTabsRef = ref.child("savedTabs");




//event listener that will update elm model upon change
savedTabsRef.on("value", function(snapshot) {
  const savedObj = snapshot.val();

  const savedArr = [];
  for (let key of Object.keys(savedObj)) {
    const val = savedObj[key];
    val.fireRef = key;
    // console.log(val);
    savedArr.push(val)
  }
  console.log(savedArr)
  app.ports.savedTabs.send(savedArr);
}, function (errorObject) {
  console.log("The read failed: " + errorObject.code);
});



function handleUpdated(tabId, changeInfo, tabInfo) {

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
    chrome.tabs.remove(tab, function() {});

    // send back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});

// Save to firebase
app.ports.save.subscribe(function(tab) {
    savedTabsRef.push(tab);
});

app.ports.activate.subscribe(function(tab) {
    // makes tab active here
    chrome.tabs.update(tab,  {selected: true} );

    // sends back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});

// removes tab from saved list
app.ports.delete.subscribe(function(url) {
    savedTabsRef.orderByChild('url').equalTo(url).on('child_added', function(snapshot) {
        console.log(snapshot.key + " was " + snapshot.val().url + " meters tall");
        savedTabsRef.child(snapshot.key).remove().then(function(){
            console.log("Remove succeeded.")
          }).catch(function(error) {
            console.log("Remove failed: " + error.message)
          })
    });
});

// Port opens saved tabs on click
app.ports.open.subscribe(function(url) {
    chrome.tabs.create({ url: url }, function (data) {
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
  const tabsElm = [];
  return data.map(function(tab){
    tabz = {
      'url' : tab.url,
      'title' : tab.title,
      'index' : tab.index,
      'active': tab.active,
      'tabID' : tab.id,
      'saved' : false,
      'favIconUrl' : tab.favIconUrl ? tab.favIconUrl : '../../icons/icon48.png'
    };
    tabsElm.push(tabz);
    return tabsElm;
  }),
  currentTabsRef.set(tabsElm),
  app.ports.initialTabs.send(tabsElm);
}
