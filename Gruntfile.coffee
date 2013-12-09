module.exports = (grunt) ->

  "use strict"

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    banner: '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - ' +
          '<%= grunt.template.today("yyyy-mm-dd") %>\n' +
          '<%= pkg.homepage ? "* " + pkg.homepage + "\\n" : "" %>' +
          '* Copyright (c) <%= grunt.template.today("yyyy") %> <%= pkg.author.name %>;' +
          ' Licensed <%= _.pluck(pkg.licenses, "type").join(", ") %> */\n'

    # coffeelintOptions:
    #   max_line_length:
    #     value: 120
    #     level: "warn"
    # coffeelint:
    #   product: ["src/coffee/*.coffee"]

    coffee:
      product:
        options:
          bare: true
        expand: true
        cwd: 'src/coffee/'
        src: '*.coffee'
        dest: 'src/js/'
        ext: '.js'

      example:
        expand: true
        options:
          bare: true
        cwd: 'example/coffee/'
        src: '*.coffee'
        dest: 'example/assets/js/'
        ext: '.js'

      test:
        expand: true
        options:
          bare: true
        cwd: 'test/spec/'
        src: '*.coffee'
        dest: 'test/spec/'
        ext: '.js'

    uglify:
      product:
        options:
          banner: "<%= banner %>"
        files:
          "src/js/kazitori.min.js": "src/js/kazitori.js"
          "src/js/kai.min.js": "src/js/kai.js"

    connect:
      jasmine:
        options:
          port: 8900
      test:
        options:
          keepalive: true
          port: 8901
          base: "test/"
      example:
        options:
          keepalive: true
          port: 8902
          base: "example/"

    livereload:
      port: 8910

    watch:
      product:
        files: ["src/coffee/*.coffee"]
        tasks: ["coffee:product", "uglify:product", "test"]
        # tasks: ["coffee:product", "uglify:product", "livereload", "test"]

      example:
        files: ["example/coffee/*.coffee"]
        tasks: ["coffee:example"]
        # tasks: ["coffee:example", "livereload"]

      test:
        files: ["test/spec/*.coffee"]
        tasks: ["coffee:test", "test"]
        # tasks: ["coffee:test", "livereload", "test"]

    # docco:
    #   kazitori:
    #     src: ["src/coffee/kazitori.coffee"]
    #     dest: "docs/"

    #   kai:
    #     src: ["src/coffee/kai.coffee"]
    #     dest: "docs/"

    jasmine:
      product:
        src: "test/src/*.js"
        options:
          host: "http://127.0.0.1:8900/"
          specs: "test/spec/*Spec.js"
          helpers: "test/spec/*Helper.js"

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-jasmine"
  grunt.loadNpmTasks "grunt-contrib-livereload"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-notify"

  grunt.registerTask "default", ["livereload-start", "coffee", "uglify", "test"]
  grunt.registerTask "test", ["connect:jasmine", "jasmine:product"]
  grunt.registerTask "ci", ["coffee", "test"]
