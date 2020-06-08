var gulp = require('gulp');
var uglify = require('gulp-uglify');
var pipeline = require('readable-stream').pipeline;
var sourcemaps = require('gulp-sourcemaps');
 
gulp.task('compress', function () {
  return pipeline(
        gulp.src('libs/*.js'),
        sourcemaps.init(),
        uglify({mangle:true}),
        sourcemaps.write(),
        gulp.dest('dist')
  );
});

