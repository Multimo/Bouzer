
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
const userRef = db.ref("users");
const auth = firebase.auth();

var loggedInUid;
var loggedInUidRef;


// main update function which sends data to elm and firebase
function updateState(data) {
  if (loggedInUid) {
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
    firebase.database().ref('users/' + loggedInUid).child("currentTabs").set(tabsElm),
    app.ports.initialTabs.send(tabsElm);
  } else return;
}

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

// check if user has logged in sets the uid from localStorage
if (localStorage.loggedInUid) {
  loggedInUid = localStorage.loggedInUid;

  app.ports.logInSuccess.send(loggedInUid);
  chrome.tabs.query({
      currentWindow: true
    }, function(data) {
      updateState(data);
  });

  savedTabs();
}

// saved tabs listener etc.
//event listener that will update elm model upon change
function savedTabs() {
  loggedInSavedRef = firebase.database().ref('users/' + loggedInUid).child("savedTabs");
  loggedInSavedRef.on("value", function(snapshot) {
    const savedObj = snapshot.val();
    const savedArr = [];
    if (savedObj) {
      for (let key of Object.keys(savedObj)) {
        const val = savedObj[key];
        val.fireRef = key;
        savedArr.push(val)
      }
    }
    app.ports.savedTabs.send(savedArr);
    }, function (errorObject) {
      console.log("The read failed: " + errorObject.code);
    });
}



// Log in function here
app.ports.logIn.subscribe(function(data) {
  var email = data[0];
  var password = data[1];
  firebase.auth().signInWithEmailAndPassword(email, password)
  .then(function(res){
    console.log(res.uid)
    loggedInUid = res.uid;
    // const dbref = db.ref(res.uid);
    localStorage.loggedInUid = loggedInUid;
    app.ports.logInSuccess.send(loggedInUid);

    // get current open tabs
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
    });

  }).catch(function(error) {

  console.log(error)
  var errorCode = error.code;
  var errorMessage = error.message;
  app.ports.logInFail.send(errorMessage);
});
  console.log(data);
});

// Log Out function here
app.ports.logOut.subscribe(function(data) {
  firebase.auth().signOut().then(function() {
    localStorage.loggedInUid = "";
  }, function(error) {
    console.log(error)
  });
});


// Create User function here
app.ports.createUser.subscribe(function(data) {
  const email = data[0];
  const password = data[1];
  firebase.auth().createUserWithEmailAndPassword(email, password)
  .then(function(res){
    console.log(res.uid)
    loggedInUid = String(res.uid);

    const newUserRef = userRef.child(loggedInUid);
    newUserRef.set({
      id: loggedInUid,
      userName: email,
      currentTabs: {},
      savedTabs: {}
    });
    const currentUserTabsRef = newUserRef.child("currentTabs");

    savedTabs();
    console.log("hi");
    console.log(loggedInSavedRef);

    localStorage.loggedInUid = loggedInUid;
    app.ports.logInSuccess.send(loggedInUid);

    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
      return newUserRef;

  }).catch(function(error) {
    console.log(error)
    var errorCode = error.code;
    var errorMessage = error.message;
    app.ports.logInFail.send(errorMessage);
});
  console.log(data);
});

// Save to firebase
app.ports.passwordReset.subscribe(function(email) {
  console.log(email);
  auth.sendPasswordResetEmail(email).then(function() {
      app.ports.logInFail.send("Email Sent!");
  }, function(error) {
    // An error happened.
  });
});



// Save to firebase
app.ports.save.subscribe(function(tab) {
    loggedInSavedRef.push(tab);
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
      loggedInSavedRef.orderByChild('url').equalTo(url).on('child_added', function(snapshot) {
        loggedInSavedRef.child(snapshot.key).remove().then(function(){
            // console.log("Remove succeeded.")
          }).catch(function(error) {
            // console.log("Remove failed: " + error.message)
          })
    });
});

// Port opens saved tabs on click
app.ports.open.subscribe(function(url) {
    chrome.tabs.create({ url: url }, function (data) {
        updateState(data);
    });
});

// port to close tabs
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
