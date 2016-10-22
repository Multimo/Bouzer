// document.addEventListener('DOMContentLoaded', function() {
//   var div = document.getElementById('widget');
//   var main = Elm.embed(Elm.Main, div, {reset:[]});
// });
//
//


// main.ports.jsToElm.send(['hi']);
// main.ports.elmToJs.subscribe(function(event) {
//     console.log(event.value);
// });

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


//
// chrome.tabs.query({
//   currentWindow: true
// },
//   function(data) {
//     console.log(data);
//     var newArray= [];
//     var tabsElm = data.map(function(tab){
//       var counter = 0;
//       console.log(counter);
//       newArray.push(tab.url);
//       counter++;
//       return newArray;
//     });
//     console.log(tabsElm);
//
//     app.ports.initalTabs.send(tabsElm);
// });

var callback = function(x) {
  console.log(x);
};
