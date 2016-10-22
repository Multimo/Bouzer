var app = Elm.Spelling.fullscreen();

app.ports.check.subscribe(function(word) {
    var suggestions = spellCheck(word);
    app.ports.suggestions.send(suggestions);
});

function spellCheck(word) {
    return [];
}


chrome.tabs.query({
    currentWindow: true
  },
    function(data) {
      var tabsElm = [];
      return data.map(function(tab){
        var tabz = [];
        tabz.push(tab.url);
        tabz.push(tab.title);
        tabsElm.push(tabz);
        return tabsElm;

      }),
      app.ports.initialTabs.send(tabsElm);
});
