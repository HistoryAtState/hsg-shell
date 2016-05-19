'use strict';

var gulp = require('gulp'),
    exist = require('gulp-exist'),
    watch = require('gulp-watch'),
    sass = require('gulp-sass'),
    uglify = require('gulp-uglify'),
    rename = require('gulp-rename'),
    imagemin = require('gulp-imagemin'),
    sourcemaps = require('gulp-sourcemaps'),
    del = require('del'),
    preprocess = require('gulp-preprocess'),
    autoprefixer = require('gulp-autoprefixer'),
    concat = require('gulp-concat')

var AUTOPREFIXER_BROWSERS = [
  'ie >= 10',
  'ie_mob >= 10',
  'ff >= 30',
  'chrome >= 34',
  'safari >= 7',
  'opera >= 23',
  'ios >= 7',
  'android >= 4.4',
  'bb >= 10'
];

var PRODUCTION = (!!process.env.NODE_ENV || process.env.NODE_ENV === 'production')

console.log('Production? %s', PRODUCTION)

exist.defineMimeTypes({
    'application/xml': ['odd']
})

var exClient = exist.createClient({
    host: 'localhost',
    port: '8080',
    path: '/exist/xmlrpc',
    basic_auth: { user: 'admin', pass: '' }
})

var targetConfiguration = {
    target: '/db/apps/hsg-shell/',
    html5AsBinary: true
}

gulp.task('clean', function() {
    return del([
      'templates/**/*',
      'build/**/*',
      'resources/css/main.css',
      'resources/fonts/*'
    ]);
});

// fonts //

gulp.task('fonts:copy', ['clean'], function () {
    return gulp.src([
            'bower_components/bootstrap-sass/assets/fonts/**/*',
            'bower_components/font-awesome/fonts/*'
        ])
        .pipe(gulp.dest('resources/fonts'))
})

gulp.task('fonts:deploy', ['fonts:copy'], function () {
    return gulp.src('resources/fonts/*', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

// images //

/**
 * Image optimization task will *overwrite* an existing image
 * with its optimized version
 */
gulp.task('images:optimize', function () {
    return gulp.src('resources/images/*')
        .pipe(imagemin({optimizationLevel: 5}))
        .pipe(gulp.dest('resources/images'))
})

gulp.task('images:deploy', function () {
    return gulp.src('resources/images/*', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('images:watch', function () {
    gulp.watch('app/images/*', ['images:deploy'])
})

// scripts //

gulp.task('scripts:build', function () {
    // minified version of js is used in production only
    return gulp.src([
            'resources/scripts/app.js',
            'resources/scripts/metagrid.js'
        ])
        .pipe(sourcemaps.init())
        .pipe(uglify())
        .pipe(sourcemaps.write())
        .pipe(rename('app.min.js'))
        .pipe(gulp.dest('resources/scripts'))
})

gulp.task('scripts:concat', ['scripts:build'], function () {
    return gulp.src([
            'bower_components/jquery/dist/jquery.min.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap.min.js',
            'resources/scripts/app.min.js'
        ])
      .pipe(concat('app.all.js'))
      .pipe(gulp.dest('resources/scripts'));
})

gulp.task('scripts:deploy', ['scripts:concat'], function () {
    return gulp.src('resources/scripts/*.js', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('scripts:watch', function () {
    gulp.watch('resources/scripts/*.js', ['scripts:deploy'])
})

// styles //
gulp.task('styles:build', ['clean'], function () {
    var compiler = sass({
        sourceMapEmbed: !PRODUCTION,
        sourceMapContents: !PRODUCTION,
        outputStyle: PRODUCTION ? 'compressed' : 'expanded'
    })
    compiler.on('error', sass.logError)
    return gulp.src('app/scss/main.scss')
        .pipe(compiler)
        .pipe(autoprefixer(AUTOPREFIXER_BROWSERS))
        .pipe(gulp.dest('resources/css'))
})

gulp.task('styles:concat', ['styles:build'], function () {
    return gulp.src([
            'resources/css/main.css',
            'resources/odd/compiled/frus.css'
        ])
      .pipe(concat('all.css'))
      .pipe(gulp.dest('resources/css'));
})

gulp.task('styles:deploy', ['styles:build', 'styles:concat'], function () {
    return gulp.src('resources/css/*.css', {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('styles:watch', function () {
    gulp.watch('app/scss/**/*.scss', ['styles:deploy'])
})

// pages //

var pagesPath = 'pages/**/*.html';
gulp.task('pages:deploy', function () {
    return gulp.src(pagesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('pages:watch', function () {
    gulp.watch(pagesPath, ['pages:deploy'])
})

// modules //

var modulesPath = 'modules/*';
gulp.task('modules:deploy', function () {
    return gulp.src(modulesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('modules:watch', function () {
    gulp.watch(modulesPath, ['modules:deploy'])
})

// templates //

var templatesPath = 'templates/**/*.html';

gulp.task('templates:build', function () {
    return gulp.src('app/' + templatesPath, {base: 'app/templates'})
        .pipe(preprocess({context: { PRODUCTION: PRODUCTION }}))
        .pipe(gulp.dest('templates'))
})

gulp.task('templates:deploy', ['templates:build'], function () {
    return gulp.src(templatesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('templates:watch', function () {
    gulp.watch(templatesPath, ['templates:deploy'])
})

// odd files //

var oddPath = 'resources/odd/**/*';
gulp.task('odd:deploy', function () {
    return gulp.src(oddPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('odd:watch', function () {
    gulp.watch(oddPath, ['odd:deploy'])
})

// files in project root //

var otherPath = '*{.xpr,.xqr,.xql,.xml,.xconf}';
gulp.task('other:deploy', function () {
    return gulp.src(otherPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('other:watch', function () {
    gulp.watch(otherPath, ['other:deploy'])
})

// general //

gulp.task('watch', ['styles:watch', 'scripts:watch', 'images:watch', 'templates:watch',
                    'pages:watch', 'odd:watch', 'other:watch', 'modules:watch'])

gulp.task('build', ['fonts:copy', 'images:optimize', 'styles:concat', 'templates:build', 'scripts:concat'])

gulp.task('deploy', ['build'], function () {
    return gulp.src([
            'resources/**/*', // odd, styles, fonts, scripts
            'bower_components/**/*',
            templatesPath,
            pagesPath,
            modulesPath,
            otherPath
        ], {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
})

gulp.task('default', ['build'])
