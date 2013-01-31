module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    coffeelintOptions: {
      "max_line_length" : {
        "value": 120,
        "level" : "warn"
      }
    },
    coffeelint: {
      files: ['src/coffee/*.coffee']
    },
    coffee:{
      app:{
        src:'src/coffee/*.coffee', dest:'src/js/'
      },
      tests:{
        src:'test/spec/*.coffee', dest:'test/spec/'
      }
    },
    min: {
      dist: {
        src:['src/js/kazitori.js'],
        dest:'src/js/kazitori.min.js'
      }
    },
    watch: {
      files: ['src/coffee/*.coffee','example/coffee/*.coffee','test/spec/*.coffee'],
      tasks: 'coffee min jasmine'
    },
    jasmine : {
      src : 'test/src/*.js',
      specs : 'test/spec/*.js'
    },
    jshint: {
      options: {
        curly: true,
        eqeqeq: true,
        immed: true,
        latedef: true,
        newcap: true,
        noarg: true,
        sub: true,
        undef: true,
        boss: true,
        eqnull: true,
        node: true,
        es5: true
      },
      globals: {
        jasmine : false,
        describe : false,
        beforeEach : false,
        expect : false,
        it : false,
        spyOn : false
      }
    }
  });

  grunt.loadNpmTasks('grunt-jasmine-runner');
  grunt.loadNpmTasks('grunt-coffee');
  grunt.loadNpmTasks('grunt-coffeelint');

  // Default task.
  grunt.registerTask('default', 'coffeelint coffee jasmine');

};
