#!/usr/bin/env node

var fs = require('fs'),
  exec = require('child_process').exec,
  _ = require('underscore');

var permissions = {
    '0': '---',
    '4': 'r--',
    '5': 'r-x',
    '6': 'rw-',
    '7': 'rwx'
  },
  filetypes = {
    '120': 'l',
    '100': '-'
  },
  sizes = ['K', 'M', 'G', 'T'];

function getPermissions(mode) {
  var filetype;
  mode = mode.toString(8);
  if (mode.length === 5) {
    filetype = 'd'
  } else {
    filetype = filetypes[mode.slice(0,3)];
  }
  mode = mode.slice(-3).split('');
  return filetype + _.map(mode, function (item) {
    return permissions[item];
  }).join('');
}

function getHumanSize(size) {
  for (var i = 0; size / 1024 > 1; i += 1) {
    size /= 1024;
  }
  size = size % 1 === 0 ? size : size.toFixed(1);
  return size + sizes[i];
}

function parse(output) {
  output = output.split('\n').slice(0, -1);
  return _.map(output, function (item) {
    var info;
    item = item.replace(/\t/g, ' ').split(' ');
    info = fs.lstatSync('./' + item[1]);
    return {
      mode: getPermissions(info.mode),
      size: parseInt(item[0]),
      name: item[1]
    }
  });
}

function logFormatted(files) {
  var output = _.map(files, function (item) {
    return _.values(item).join('\t');
  }).join('\n');
  console.log(output);
}

function sortByKey(arr, key, desc) {
  var direction = desc ? -1 : 1;
  return arr.sort(function (a, b) {
    var result = (a[key] < b[key]) ? -1 : (a[key] > b[key]) ? 1 : 0;
    return result * direction;
  });
}

function convertSizes(files) {
  return _.map(files, function (file) {
    file.size = getHumanSize(file.size);
    return file
  });
}

exec('du -s *', function (err, stdout, stderr) {
  var files = parse(stdout.toString());
  files = sortByKey(files, 'size', true);
  files = convertSizes(files);
  logFormatted(files);
});

