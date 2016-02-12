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

function deployTaskFor(sourcePath) {
    return function () {
        return gulp.src(sourcePath, {base: '.'})
            .pipe(exist.newer(existConfiguration))
            .pipe(exist.dest(existConfiguration))
    }
}

function watchTaskFor(sourcePath) {
    return function () {
        return gulp.src(sourcePath, {base: '.'})
            .pipe(watch(sourcePath))
            .pipe(exist.dest(existConfiguration))
    }
}

gulp.task('watch.modules', watchTaskFor('./modules/*'))
gulp.task('watch.templates', watchTaskFor('./templates/*'))
gulp.task('watch.resources', watchTaskFor('./resources/**/*'))
gulp.task('watch.pages', watchTaskFor('./pages/**/*'))

gulp.task('sass', function () {
    return gulp.src('./resources/sass/main.scss', {base: '.'})
        .pipe(sass().on('error', sass.logError))
        .pipe(gulp.dest('./resources/css'))
})

gulp.task('watch.styles', ['watch.resources'], function () {
    gulp.watch('./resources/sass/**/*.scss', ['sass'])
})

gulp.task('watch', [
    'watch.modules',
    'watch.templates',
    'watch.resources',
    'watch.pages'
])

gulp.task('deploy.modules', deployTaskFor('./modules/*'))
gulp.task('deploy.templates', deployTaskFor('./templates/*'))
gulp.task('deploy.resources', deployTaskFor('./resources/**/*'))
gulp.task('deploy.pages', deployTaskFor('./pages/**/*'))

gulp.task('default', [
    'deploy.modules',
    'deploy.templates',
    'deploy.resources',
    'deploy.pages'
])

// TODO package deployment fails due to missing build folder in eXistDB
//gulp.task('deploy.package', deployTaskFor('build/*.xar'))
//gulp.task('default', ['deploy.package'])
