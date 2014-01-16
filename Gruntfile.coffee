module.exports = (grunt) ->
  require("load-grunt-tasks")(grunt)

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    barrier:
      unit: ["test/helper.coffee", "test/**/*_test.coffee"]

    "curl-dir":
      fixtureVideos:
        files:
          "test/fixtures": [
            "http://thesubdb.com/api/samples/dexter.mp4"
            "http://www.opensubtitles.org/addons/avi/breakdance.avi"
          ]

    watch:
      options:
        spawn: false

      barrier:
        files: ["lib/**", "test/**"]
        tasks: ["barrier:unit"]

  grunt.registerTask "default", ["barrier", "watch:barrier"]
