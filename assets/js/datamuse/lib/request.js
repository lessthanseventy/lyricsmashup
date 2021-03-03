"use strict";
const got = require("got");

const options = {
  json: true,
};

module.exports = (postUri) => {
  return got(
    `https://cryptic-hamlet-30617.herokuapp.com/https://api.datamuse.com/${postUri}`,
    options
  ).then((response) => {
    return response.body;
  });
};
