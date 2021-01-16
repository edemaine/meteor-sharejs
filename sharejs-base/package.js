Package.describe({
  name: "edemaine:sharejs",
  summary: "server (& client library) to allow concurrent editing of any kind of content",
  version: "0.10.3-alpha.4",
  git: "https://github.com/edemaine/meteor-sharejs.git"
});

Npm.depends({
  // Fork of 0.6.3 that avoids many require()s, starting with:
  // https://github.com/meteor/meteor/issues/532#issuecomment-82635979
  // Includes "Failed to parse" bugfix
  share: "https://github.com/edemaine/ShareJS/tarball/b7cb38a224eb49963eab5fd592643ea396e03acd",
  browserchannel: '1.2.0'
});

Package.onUse(function (api) {
  api.versionsFrom("1.3");

  api.use(['underscore', 'ecmascript', 'modules']);
  api.use(['handlebars', 'templating'], 'client');
  api.use(['mongo-livedata', 'routepolicy', 'webapp'], 'server');


  api.mainModule('sharejs-client.js', 'client');
  api.mainModule('sharejs-server.js', 'server');
  // Our files
  api.addFiles([
      'sharejs-templates.html'
  ], 'client');

});

Package.onTest(function (api) {
  api.use([
    'random',
    'ecmascript',
    'modules',
    'tinytest',
    'test-helpers'
  ]);

  api.use("edemaine:sharejs");

  api.addFiles('tests/server_test.js', 'server');
});
