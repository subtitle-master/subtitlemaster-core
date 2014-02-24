require("coffee-script");

module.exports = {
  SearchDownload:    require("./lib/interactors/search_download.coffee"),
  VideoScan:         require("./lib/interactors/video_scan.coffee"),
  AlternativeSearch: require("./lib/interactors/alternative_search.coffee"),
  OrganizeMedia:     require("./lib/interactors/organize_media.coffee")
};
