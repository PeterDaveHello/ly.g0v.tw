name: "ly.g0v.tw"
repo: "g0v/ly.g0v.tw"
version: "0.1.1"
main: "_public/js/app.js"
ignore: ["**/.*", "node_modules", "components"]
dependencies:
  jquery: "~2.0.3"
  angular: "1.2.2"
  "angular-mocks": "1.2.2"

overrides:
  "angular-mocks":
    main: "README.md"