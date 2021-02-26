"use strict";
const fetch = require("node-fetch");
const cheerio = require("cheerio");
const Markov = require("markov-generator");

const accessToken =
  "?access_token=KuENUxCaPSBuM168bMWkyIkpXELItXXfk-smz15ChsPwNA5zAKr5Rg5VxHvfol17";

document.onload = init();

function init() {
  async function onSubmit() {
    let lyrics = document.getElementById("lyrics");
    while (lyrics.firstChild) {
      lyrics.removeChild(lyrics.firstChild);
    }
    let loadingBar = document.getElementById("loadingBar");
    loadingBar.classList.remove("is-hidden");
    let lyricsColumn = document.getElementById("lyricsColumn");
    let inputColumn = document.getElementById("inputColumn");
    inputColumn.classList.remove("is-offset-3");
    lyricsColumn.classList.remove("is-hidden");
    let inputValue = document.getElementById("inputForm").value.toString();
    await artistByName(inputValue)
      .then((res) => songsOutput(res))
      .then((res) => loopForLyrics(res))
      .then((lyrics) => generateSong(lyrics));
  }

  async function _request(path) {
    const url = `https://cryptic-hamlet-30617.herokuapp.com/https://api.genius.com/${path}`;

    // Fetch result and parse it as JSON
    const body = await fetch(url);
    const result = await body.json();

    // Handle errors
    if (result.error)
      throw new Error(`${result.error}: ${result.error_description}`);
    if (result.meta.status !== 200)
      throw new Error(`${result.meta.status}: ${result.meta.message}`);

    return result.response;
  }

  /*
Get song by ID
*/

  async function song(id, { fetchLyrics = false, textFormat = "dom" } = {}) {
    if (!id) throw new Error("No ID was provided to lyricist.song()");

    const path = `songs/${id}${accessToken}&?text_format=${textFormat}`;
    const { song } = await _request(path);

    const lyrics = fetchLyrics ? await _scrapeLyrics(song.url) : null;

    return Object.assign({ lyrics }, song);
  }

  /* Get artist by ID */

  async function artist(id, { textFormat = "dom" } = {}) {
    if (!id) throw new Error("No ID was provided to lyricist.artist()");

    const path = `artists/${id}${accessToken}&?text_format=${textFormat}`;
    const { artist } = await _request(path);
    return artist;
  }

  async function artistByName(name) {
    const slug = _geniusSlug(name);
    const id = await _scrapeArtistPageForArtistID(slug);
    return songsByArtist(id);
  }

  /* Get artist songs */

  async function songsByArtist(
    id,
    { page = 1, perPage = 10, sort = "popularity" } = {}
  ) {
    if (!id) throw new Error("No ID was provided to lyricist.songsByArtist()");

    const path = `artists/${id}/songs${accessToken}&per_page=${perPage}&page=${page}&sort=${sort}`;
    const { songs } = await _request(path);

    return songs;
  }

  /* Scrape song lyrics */

  async function _scrapeLyrics(url) {
    let corsUrl = `https://cryptic-hamlet-30617.herokuapp.com/${url}`;
    const response = await fetch(corsUrl);
    const text = await response.text();
    const $ = cheerio.load(text);
    return $(".lyrics").text().trim();
  }

  /* Get slug from name/title */

  function _geniusSlug(string) {
    // Probably not 100% accurate yet
    // Currently only used by undocumented artistByName function
    const slug = string
      .trim()
      .replace(/\s+/g, "-")
      .replace("'", "")
      .replace("&", "and")
      .replace(/[^a-zA-Z0-9]/g, "-")
      .toLowerCase();
    // Uppercase first letter
    return slug.charAt(0).toUpperCase() + slug.slice(1);
  }

  /* Scrape artist page to retrieve artist ID */

  async function _scrapeArtistPageForArtistID(slug) {
    const url = `https://cryptic-hamlet-30617.herokuapp.com/https://genius.com/artists/${slug}`;
    const html = await fetch(url).then((res) => res.text());
    const $ = cheerio.load(html);
    const id = $('meta[name="newrelic-resource-path"]')
      .attr("content")
      .split("/")
      .pop();
    return id;
  }
  /* Populate list of songs */
  async function songsOutput(arrayOfSongs) {
    let html = `<div class="content"><h1 id="songsHeading" class="has-text-success">${arrayOfSongs[9].primary_artist.name} Top Songs</h1><ol class="is-medium has-text-success" type="1">`;
    let elem = document.getElementById("songsOutput");
    for (let i = 0; i < arrayOfSongs.length; i++) {
      html +=
        "<li>" + arrayOfSongs[i].full_title.replace(/ by.*/g, "") + "</li>";
    }
    html += "</ol></div>";
    elem.innerHTML = html;
    return arrayOfSongs;
  }
  /* Loop through array of song ids and return cleaned array of strings to pass to Markov Generator */
  async function loopForLyrics(arr) {
    let temp = [];
    let lyricsArray = [];
    for (let i = 0; i < arr.length; i++) {
      await song(arr[i].id, { fetchLyrics: true }).then(function (res) {
        /* remove [Verse] and such and any parentheses */
        temp.push(
          res.lyrics.replace(/ *\[[^\]]*\] */g, "").replace(/[\(\)]/g, "")
        );
      });
    }
    /* Split temp array at newllnes an push to output array */
    for (let i = 0; i < temp.length; i++) {
      let a = temp[i].split("\n");
      for (let j = 0; j < a.length; j++) {
        lyricsArray.push(a[j]);
      }
    }
    return lyricsArray;
  }

  /* Generate song using passed in array of lyrics */
  async function generateSong(arrayOfLyrics) {
    let titleMarkov = new Markov({
      input: arrayOfLyrics,
      minLength: 5,
      maxLength: 7,
    });
    let title = titleMarkov.makeChain();
    console.log(title);
    let html = `<div class="is-size-7-mobile"><h1 class="has-text-primary">${title}</h1>`;
    for (let i = 0; i < 24; i++) {
      let markov = new Markov({
        input: arrayOfLyrics,
        minLength: 9,
        maxLength: 13,
      });
      let sentence = markov.makeChain();
      if (i != 0 && i % 4 == 0) {
        html += "<div><br></div>";
      }
      html += "<div>" + sentence + "</div>";
    }
    document.getElementById("loadingBar").classList.add("is-hidden");
    document.getElementById("lyrics").innerHTML = html;
  }
}
export var Post = {
  run: function () {
    // put initializer stuff here
    // for example:
    document.getElementById("inputButton").addEventListener("click", onSubmit);
  },
};
