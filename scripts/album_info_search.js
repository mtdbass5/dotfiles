#!/usr/bin/env node

var  _ = require('underscore'),
  fs = require('fs'),
  os = require('os'),
  util = require('util'),
  async = require('async'),
  request = require('request'),
  readline = require('readline');

var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function logAlbumInfo(album) {
  console.log('Album: ' + album.name);
  console.log('Artist: ' + album.artist);
}

function stepPrompt(arr, callback) {
  async.detectSeries(arr,
    function (item, callback) {
      logAlbumInfo(item);
      rl.question('Is this correct? (y, n): ', function (res) {
        callback(res.toLowerCase() === 'y');
      });
    },
    function (result) {
      rl.pause();
      if (!result) {
        callback('No more items');
      } else {
        callback(null, result);
      }
    }
  );
}

function parseAlbumSearch(body) {
  var items = JSON.parse(body).albums.slice(0, 10);
  return _.map(items, function (i) {
    i.id = i.href.split(':')[2];
    i.artist = i.artists[0].name;
    return _.pick(i, 'name', 'id', 'artist');
  });
}

function parseAlbumLookup(body) {
  var album = JSON.parse(body).album;
  album.tracks = _.map(album.tracks, function (track, index) {
    index += 1;
    index = index < 10 ? '0' + index : index;
    return {
      name: track.name,
      index: index,
      oldName: 'track' + index + '.cdda.flac',
      newName: '"' + index + ' ' + track.name + '.flac"'
    };
  });
  return _.pick(album, 'name', 'artist', 'released', 'tracks');
}

function genTagCmds(album) {
  var cmds = [
    genTagCmd('DATE', album.released, '*.flac'),
    genTagCmd('ALBUM', album.name, '*.flac'),
    genTagCmd('ARTIST', album.artist, '*.flac'),
  ];
  _.each(album.tracks, function (track) {
    cmds.push(genTagCmd('TRACKNUMBER', track.index, track.oldName));
    cmds.push(genTagCmd('TITLE', track.name, track.oldName));
  });
  return cmds;
}

function genTagCmd(tagname, value, filename) {
  return 'metaflac --set-tag="' + tagname + '=' + value + '" ' + filename;
}

function getCommandText(album) {
  var folder = '~/media/music/"' + album.artist + '"/"' + album.name + '"';
  var cmds = genTagCmds(album);
  _.each(album.tracks, function (track) {
    cmds.push('mv ' + track.oldName + ' ' + track.newName);
  });
  cmds.push('mkdir -p ' + folder);
  cmds.push('mv *.flac ' + folder);
  return cmds.join(os.EOL) + os.EOL;
}

function insertNullArg(callback) {
  return function () {
    var args = _.toArray(arguments);
    args.unshift(null);
    callback.apply(this, args);
  };
}

async.waterfall([
  function (callback) {
    rl.question('Enter Album Query: ', insertNullArg(callback));
  },
  function (res, callback) {
    request('http://ws.spotify.com/search/1/album.json?q=' + res, callback);
  },
  function (res, body, callback) {
    stepPrompt(parseAlbumSearch(body), callback);
  },
  function (res, callback) {
    request('http://ws.spotify.com/lookup/1/.json?extras=track&uri=spotify:album:' + res.id, callback);
  },
  function (res, body, callback) {
    fs.writeFile('./command', getCommandText(parseAlbumLookup(body)), callback);
  }
], function (err) {
    console.log(err || 'Done');
  }
);
