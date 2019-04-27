Package.describe({
  name: "edemaine:sharejs-codemirror",
  summary: "ShareJS with the CodeMirror Editor",
  version: "5.39.2-alpha.3",
  git: "https://github.com/edemaine/meteor-sharejs.git"
});

Package.onUse(function (api) {
  api.versionsFrom("1.3.2");

  api.use(['ecmascript', 'modules', 'templating']);

  api.use("edemaine:sharejs@0.10.3-alpha.2");
  api.imply("edemaine:sharejs");

  api.mainModule('client.js', 'client');
  api.addFiles([
    'templates.html'
  ], 'client');
});
