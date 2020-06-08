使用gulp-minify-css压缩css文件，减小文件大小，并给引用url添加版本号避免缓存。重要：gulp-minify-css已经被废弃，请使用gulp-clean-css，用法一致。

$ npm install gulp-minify-css --save-dev

### 配置 gulpfile.js
---------------------------------------------------------------------
var gulp = require('gulp'),
    cssmin = require('gulp-minify-css');
 
gulp.task('cssmin', function () {
    gulp.src('src/css/*.css')
        .pipe(cssmin({
            advanced: false, //类型：Boolean 默认：true [是否开启高级优化（合并选择器等）]
            compatibility: 'ie7', //保留ie7及以下兼容写法 类型：String 默认：''or'*' [启用兼容模式； 'ie7'：IE7兼容模式，'ie8'：IE8兼容模式，'*'：IE9+兼容模式]
            keepBreaks: true //类型：Boolean 默认：false [是否保留换行]
        }))
        .pipe(gulp.dest('dist/css'));
});

### 若想保留 css 注释，这样注释即可：
---------------------------------------------------------------------
/*!
   Important comments included in minified output.
*/

### 命令行之行 gulp
---------------------------------------------------------------------
$ gulp cssmin