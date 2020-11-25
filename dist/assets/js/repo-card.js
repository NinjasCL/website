(function () {
  'use strict';

  // Modified version of https://github.com/Tarptaeya/repo-card
  (function () {
    var getEmojis = function getEmojis() {
      return fetch("/assets/js/emojis.json").then(function (resp) {
        return resp.json();
      });
    };

    var getColors = function getColors() {
      return fetch("/assets/js/colors.json").then(function (resp) {
        return resp.json();
      });
    };

    var getRepoData = function getRepoData(name) {
      var data = localStorage.getItem(name);

      if (data) {
        return Promise.resolve(JSON.parse(data));
      }

      return fetch("https://api.github.com/repos/" + name).then(function (resp) {
        return resp.json();
      }).then(function (json) {
        localStorage.setItem(name, JSON.stringify(json));
        return json;
      });
    };

    var html = function html(data, colors) {
      return "\n<div style=\"font-family: -apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji; border: 1px solid #e1e4e8; border-radius: 6px; background: white; padding: 16px; font-size: 14px; line-height: 1.5; color: #24292e;\">\n  <div style=\"display: flex; align-items: center;\">\n    <svg style=\"fill: #586069; margin-right: 8px;\" viewBox=\"0 0 16 16\" version=\"1.1\" width=\"16\" height=\"16\" aria-hidden=\"true\"><path fill-rule=\"evenodd\" d=\"M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z\"></path></svg>\n    <span style=\"font-weight: 600; color: #0366d6;\">\n      <a style=\"text-decoration: none; color: inherit;\" href=\"".concat(data.html_url, "\">").concat(data.name, "</a>\n    </span>\n  </div>\n  <div style=\"display: ").concat(data.fork ? "block" : "none", "; font-size: 12px; color: #586069;\">Forked from <a style=\"color: inherit; text-decoration: none;\" href=\"").concat(data.fork ? data.source.html_url : "", "\">").concat(data.fork ? data.source.full_name : "", "</a></div>\n  <div style=\"font-size: 12px; margin-bottom: 16px; margin-top: 8px; color: #586069;\">").concat(data.description, "</div>\n  <div style=\"font-size: 12px; color: #586069; display: flex;\">\n    \n    <div style=\"margin-right: 16px;\">\n      <span style=\"width: 12px; height: 12px; border-radius: 100%; background-color: ").concat(colors[data.language] ? colors[data.language].color : "#3c3c3c", "; display: inline-block; top: 1px; position: relative;\"></span>\n      <span>").concat(data.language || "", "</span>\n    </div>\n    <div style=\"display: flex; align-items: center; margin-right: 16px;\">\n      <svg style=\"fill: #586069;\" aria-label=\"stars\" viewBox=\"0 0 16 16\" version=\"1.1\" width=\"16\" height=\"16\" role=\"img\"><path fill-rule=\"evenodd\" d=\"M8 .25a.75.75 0 01.673.418l1.882 3.815 4.21.612a.75.75 0 01.416 1.279l-3.046 2.97.719 4.192a.75.75 0 01-1.088.791L8 12.347l-3.766 1.98a.75.75 0 01-1.088-.79l.72-4.194L.818 6.374a.75.75 0 01.416-1.28l4.21-.611L7.327.668A.75.75 0 018 .25zm0 2.445L6.615 5.5a.75.75 0 01-.564.41l-3.097.45 2.24 2.184a.75.75 0 01.216.664l-.528 3.084 2.769-1.456a.75.75 0 01.698 0l2.77 1.456-.53-3.084a.75.75 0 01.216-.664l2.24-2.183-3.096-.45a.75.75 0 01-.564-.41L8 2.694v.001z\"></path></svg>\n      &nbsp; <span>").concat(data.stargazers_count, "</span>\n    </div>\n    <div style=\"display: flex; align-items: center;\">\n      <svg style=\"fill: #586069;\" aria-label=\"fork\" viewBox=\"0 0 16 16\" version=\"1.1\" width=\"16\" height=\"16\" role=\"img\"><path fill-rule=\"evenodd\" d=\"M5 3.25a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm0 2.122a2.25 2.25 0 10-1.5 0v.878A2.25 2.25 0 005.75 8.5h1.5v2.128a2.251 2.251 0 101.5 0V8.5h1.5a2.25 2.25 0 002.25-2.25v-.878a2.25 2.25 0 10-1.5 0v.878a.75.75 0 01-.75.75h-4.5A.75.75 0 015 6.25v-.878zm3.75 7.378a.75.75 0 11-1.5 0 .75.75 0 011.5 0zm3-8.75a.75.75 0 100-1.5.75.75 0 000 1.5z\"></path></svg>\n      &nbsp; <span>").concat(data.forks, "</span>\n    </div>\n  </div>\n</div>\n");
    };

    window.addEventListener("DOMContentLoaded", function () {
      return getEmojis().then(function (emojis) {
        return getColors().then(function (colors) {
          document.querySelectorAll(".repo-card").forEach(function (el) {
            var name = el.getAttribute("data-repo");
            return getRepoData(name).then(function (data) {
              data.description = data.description.replace(/:\w+:/g, function (match) {
                var ename = match.substring(1, match.length - 1);
                var emoji = emojis[ename];

                if (emoji) {
                  return "<span><img src=\"".concat(emoji, "\" style=\"width: 1rem; height: 1rem; vertical-align: -0.2rem;\"></span>");
                }

                return match;
              });
              el.innerHTML = html(data, colors);
            });
          });
        });
      });
    });
  })();

}());
