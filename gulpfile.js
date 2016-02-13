'use strict';

var gulp = require('gulp'),
    exist = require('gulp-exist'),
    watch = require('gulp-watch'),
    sass = require('gulp-sass'),
    uglify = require('gulp-uglify'),
    rename = require('gulp-rename'),
    imagemin = require('gulp-imagemin'),
    sourcemaps = require('gulp-sourcemaps'),
    del = require('del')

exist.createClient({
    host: 'localhost',
    port: '8080',
    path: '/exist/xmlrpc',
    basic_auth: { user: 'admin', pass: '' }
})

var existConfiguration = {
    target: '/db/apps/hsg-shell/',
    retry: true
}

gulp.task('clean', function() {
    return del([
        'resources/css/main.css',
        'resources/fonts/*',
        'resources/scripts/*',
        'resources/images/*'
    ]);
});

// fonts //

gulp.task('fonts:copy', function () {
    return gulp.src('node_modules/bootstrap-sass/assets/fonts/bootstrap/*')
        .pipe(gulp.dest('resources/fonts'))
})

gulp.task('fonts:deploy', ['fonts:copy'], function () {
    return gulp.src('resources/fonts/*', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

// images //

/**
 * TODO optimize
 */
gulp.task('images:optimize', function () {
    return gulp.src('app/images/*')
        .pipe(imagemin({optimizationLevel: 5}))
        .pipe(gulp.dest('resources/images'))
})

gulp.task('images:deploy', ['images:optimize'], function () {
    return gulp.src('resources/images/*', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

gulp.task('images:watch', function () {
    gulp.watch('app/images/*', ['images:deploy'])
})

// scripts //

/**
 * TODO: concat, minify
 */
gulp.task('scripts:build', function () {
    return gulp.src('app/js/app.js')
        .pipe(gulp.dest('resources/scripts'))
        .pipe(sourcemaps.init())
        .pipe(uglify())
        .pipe(sourcemaps.write())
        .pipe(rename('app.min.js'))
        .pipe(gulp.dest('resources/scripts'))
})

gulp.task('scripts:deploy', ['scripts:build'], function () {
    return gulp.src('resources/scripts/*.js', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

gulp.task('scripts:watch', function () {
    gulp.watch('app/js/**/*.js', ['scripts:deploy'])
})

// styles //

/**
 * TODO: minify, source map
 */
gulp.task('styles:build', function () {
    return gulp.src('app/scss/main.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('resources/css'))
})

gulp.task('styles:deploy', ['styles:build'], function () {
    return gulp.src('resources/css/*.css', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

gulp.task('styles:watch', function () {
    gulp.watch('app/scss/**/*.scss', ['styles:deploy'])
})

// pages //

// modules //

// templates //

// other files //

// general //

gulp.task('watch', ['styles:watch', 'scripts:watch', 'images:watch'])
gulp.task('build', ['styles:build', 'scripts:build', 'fonts:copy', 'images:optimize'])
gulp.task('deploy', ['build'], function () {
    return gulp.src('resources/**/*', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

gulp.task('default', ['clean', 'build'])
