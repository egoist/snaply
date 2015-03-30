gulp = require 'gulp'
coffee = require 'gulp-coffee'
stylus = require 'gulp-stylus'
nodemon = require 'gulp-nodemon'
livereload = require 'gulp-livereload'

paths = 
  stylus: 'assets/stylus/*.styl',
  coffee: 'assets/coffee/*.coffee',
  core: 'coffee/*.coffee'

gulp.task 'develop', ->
  nodemon(
    script: 'index.js'
    ext: 'html js'
    ignore: [ 'assets/js/*.js' ],
    execMap: {
      js: 'iojs'
    }
  ).on 'restart', ->
      console.log 'restarted!'

gulp.task 'stylus', ->
  gulp.src paths.stylus
    .pipe stylus compress: true
    .pipe gulp.dest __dirname + '/assets/css'
    .pipe livereload()

gulp.task 'core', ->
  gulp.src paths.core
    .pipe coffee bare: true
    .pipe gulp.dest __dirname + '/core'
    .pipe livereload()

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe coffee bare: true
    .pipe gulp.dest __dirname + '/assets/js'
    .pipe livereload()

gulp.task 'watch', ->
  livereload start: true 
  livereload.listen
  gulp.watch paths.stylus, ['stylus']
  gulp.watch paths.core, ['core']
  gulp.watch paths.coffee, ['coffee']

gulp.task 'build', ['stylus', 'core', 'coffee']

gulp.task 'default', ['build', 'develop', 'watch']