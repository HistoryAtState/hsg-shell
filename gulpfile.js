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
    return gulp.src('./resources/app/scss/main.scss')
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./resources/css'))
})

gulp.task('styles:deploy', ['styles:build'], function () {
    return gulp.src('./resources/css/*.css', {base: '.'})
        .pipe(exist.newer(existConfiguration))
        .pipe(exist.dest(existConfiguration))
})

gulp.task('styles:watch', function () {
    gulp.watch('./resources/app/scss/**/*.scss', ['styles:deploy'])
})

gulp.task('watch', ['styles:watch'])
gulp.task('build', ['styles:build'])
gulp.task('deploy', ['styles:deploy'])

gulp.task('default', ['build'])
