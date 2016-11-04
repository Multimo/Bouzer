
var app = Elm.Spelling.fullscreen();

app.ports.check.subscribe(function(word) {
    // var suggestions = spellCheck(word);
    app.ports.suggestions.send(suggestions);
});

app.ports.close.subscribe(function(tab) {
    // close tab here
    console.log(tab);
    chrome.tabs.remove(tab, function() { });

    // send back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});



chrome.tabs.query({
    currentWindow: true
  }, function(data) {
    updateState(data);
  });


app.ports.activate.subscribe(function(tab) {
    // make tab active here
    console.log(tab);
    chrome.tabs.update(tab,  {selected: true} );

    // send back new state here
    chrome.tabs.query({
        currentWindow: true
      }, function(data) {
        updateState(data);
      });
});






function updateState(data) {
  var tabsElm = [];
  return data.map(function(tab){
    // console.log(tab);
    tabz = {
      'url' : tab.url,
      'title' : tab.title,
      'active': tab.active,
      'tabID' : tab.id,
      'favIconUrl' : tab.favIconUrl ? tab.favIconUrl : '../../icons/icon48.png'
    };
    tabsElm.push(tabz);
    return tabsElm;

  }),
  app.ports.initialTabs.send(tabsElm);
}
