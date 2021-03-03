// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import "core-js/stable";
import "regenerator-runtime/runtime";
const fetch = require("node-fetch");
const cheerio = require("cheerio");
const Markov = require("markov-generator");
const datamuse = require("./datamuse");

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

const accessToken =
  "?access_token=KuENUxCaPSBuM168bMWkyIkpXELItXXfk-smz15ChsPwNA5zAKr5Rg5VxHvfol17";

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

let Hooks = {};
Hooks.Lyrics = {
  mounted() {
    document.getElementById("genButton").addEventListener("click", onSubmit);
    document.getElementById("addButton").addEventListener("click", onSubmit);
    document.getElementById("clearButton").addEventListener("click", reinit);
    const view = this;
    let lyricsArray = [];
    let songToSave = {};

    function sleep(ms) {
      return new Promise((resolve) => setTimeout(resolve, ms));
    }
    function reinit() {
      lyricsArray = [];
      document.getElementById("lyrics").innerHTML = "";
      document.getElementById("songsOutput").innerHTML = "";
      document.getElementById("genButton").style.display = "block";
      document.getElementById("addButton").style.display = "none";
      document.getElementById("clearButton").style.display = "none";
      document.getElementById("saveButton").style.display = "none";
      document.getElementById("loadingSpinner").style.display = "none";
    }
    async function onSubmit() {
      document.getElementById("genButton").style.display = "none";
      document.getElementById("addButton").style.display = "block";
      document.getElementById("clearButton").style.display = "block";
      document.getElementById("loadingSpinner").style.display = "block";
      document.getElementById("saveButton").style.display = "block";

      let lyrics = document.getElementById("lyrics");
      while (lyrics.firstChild) {
        lyrics.removeChild(lyrics.firstChild);
      }

      let inputValue = document.getElementById("inputForm").value.toString();

      await artistByName(inputValue)
        .then((res) => songsOutput(res))
        .then((songs) => loopForLyrics(songs))
        .then((lyrics) => generateSong(lyrics))
        .then((song) => (songToSave = song))
        .catch((err) => {
          view.pushEvent("bandError", {});
          reinit();
        });
    }

    async function getRhymingWord(word) {
      let counter = 0;
      let rhymingWord;
      const url = `https://cryptic-hamlet-30617.herokuapp.com/https://api.datamuse.com/words?rel_rhy=${word}`;
      const body = await fetch(url);
      const result = await body.json();
      if (result) {
        rhymingWord = result[counter];
        console.log(rhymingWord);
        if (!rhymingWord || rhymingWord.length < 3) {
          return undefined;
        }
      }
      if (result.error) {
        throw new Error(`${result.error}: ${result.error_description}`);
      }
      console.log(result);
      return rhymingWord;
    }
    async function _request(path) {
      const url = `https://cryptic-hamlet-30617.herokuapp.com/https://api.genius.com/${path}`;

      // Fetch result and parse it as JSON
      const body = await fetch(url);
      const result = await body.json();

      // Handle errors
      if (result.error) {
        console.log(result);
        throw new Error(`${result.error}: ${result.error_description}`);
      }
      if (result.meta.status !== 200) {
        console.log(result);
        throw new Error(`${result.meta.status}: ${result.meta.message}`);
      }

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
      if (!id)
        throw new Error("No ID was provided to lyricist.songsByArtist()");

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
      let html = `<div id="songsContent"><h1 id="songsHeading">${arrayOfSongs[9].primary_artist.name}</h1><ol type="1">`;
      let elem = document.getElementById("songsOutput");
      for (let i = 0; i < arrayOfSongs.length; i++) {
        html +=
          "<li>" + arrayOfSongs[i].full_title.replace(/ by.*/g, "") + "</li>";
      }
      html += "</ol></div>";
      elem.innerHTML += html;
      return arrayOfSongs;
    }
    /* Loop through array of song ids and return cleaned array of strings to pass to Markov Generator */
    async function loopForLyrics(arr) {
      let temp = [];
      for (let i = 0; i < arr.length; i++) {
        await sleep(250);
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
      let title;
      do {
        title = titleMarkov.makeChain();
      } while (
        title.split(" ")[0].length > 12 ||
        title.split(" ")[0] == title.split(" ")[1] ||
        title.split(" ")[1] == title.split(" ")[2]
      );
      let html = `<div id="lyricsResult"><h1 class="has-text-primary">${title}</h1>`;
      for (let i = 0; i < 12; i++) {
        let markov = new Markov({
          input: arrayOfLyrics,
          minLength: 8,
          maxLength: 11,
        });
        let firstLine = markov
          .makeChain()
          .replace(/[.,\/#!$?%\^&\*;:{}=\_`~()"]/g, "") // Remove punctuation
          .replace(/\s{2,}/g, " "); // Fix double spaces from ^
        let rhymer = firstLine.split(" ").pop();
        let rhymingWord = await getRhymingWord(rhymer);
        while (
          firstLine.split(" ")[0].toLowerCase() ==
            firstLine.split(" ")[1].toLowerCase() ||
          firstLine.split(" ")[1].toLowerCase() ==
            firstLine.split(" ")[2].toLowerCase() ||
          firstLine.split(" ")[0].length > 10 ||
          !rhymingWord
        ) {
          firstLine = markov
            .makeChain()
            .replace(/[.,\/#!$?%\^&\*;:{}=\_`~()"]/g, "") // Remove punctuation
            .replace(/\s{2,}/g, " "); // Fix double spaces from ^
          rhymer = firstLine.split(" ").pop();
          rhymingWord = await getRhymingWord(rhymer);
        }
        let secondLine = markov
          .makeChain()
          .replace(/[.,\/#!$?%\^&\*;:{}=\_`~()]/g, "")
          .replace(/\s{2,}/g, " ");
        // Regenerate line if first two words are duplicated
        while (
          secondLine.split(" ")[0].toLowerCase() ==
            secondLine.split(" ")[1].toLowerCase() ||
          secondLine.split(" ")[1].toLowerCase() ==
            secondLine.split(" ")[2].toLowerCase() ||
          secondLine.split(" ")[0].length > 10
        ) {
          secondLine = markov
            .makeChain()
            .replace(/[.,\/#!$?%\^&\*;:{}=\_`~()]/g, "") // Remove punctuation
            .replace(/\s{2,}/g, " "); // Fix double spaces from ^
        }
        secondLine += ` ${rhymingWord.word.toString()}`;
        if (i != 0 && i % 2 == 0) {
          html += "<div><br></div>";
        }
        html += "<div>" + firstLine + "</div>";
        html += "<div>" + secondLine + "</div>";
      }

      document.getElementById("loadingSpinner").style.display = "none";
      document.getElementById("lyrics").innerHTML = html;
      let songToSave = {
        title: title.toString(),
        lyrics: html.toString(),
      };
      return songToSave;
    }
    var listener = {
      handleEvent: function (event) {
        view.pushEvent("saveSong", songToSave);
        reinit();
      },
    };
    document.getElementById("saveButton").addEventListener("click", listener);
  },
};

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
