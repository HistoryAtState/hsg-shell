'use strict';

var gulp = require('gulp'),
    exist = require('gulp-exist'),
    watch = require('gulp-watch'),
    sass = require('gulp-sass')

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

gulp.task('styles:build', function () {
    return gulp.src('./resources/sass/main.scss', {base: '.'})
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./resources/css'))
})

gulp.task('styles:deploy', function () {
    return gulp.src('./resources/css/*.css', {base: '.'})
        .pipe(exist.dest(existConfiguration))
})

gulp.task('styles:watch', function () {
    gulp.watch('./resources/css/*.css', ['styles:deploy'])
    gulp.watch('./resources/sass/**/*.scss', ['styles:build'])
})

gulp.task('default', ['styles:watch'])
