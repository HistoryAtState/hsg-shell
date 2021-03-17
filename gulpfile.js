'use strict';

const gulp = require('gulp'),
    fs = require('fs'),
    exist = require('@existdb/gulp-exist'),
    sass = require('gulp-sass'),
    uglify = require('gulp-uglify'),
    imagemin = require('gulp-imagemin'),
    del = require('del'),
    preprocess = require('gulp-preprocess'),
    autoprefixer = require('gulp-autoprefixer'),
    concat = require('gulp-concat');

const AUTOPREFIXER_BROWSERS = [
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

const PRODUCTION = (!!process.env.NODE_ENV && process.env.NODE_ENV === 'production');

console.log('Production? %s', PRODUCTION);

let localConnectionOptions = {};

if (fs.existsSync('./local.node-exist.json')) {
  localConnectionOptions = require('./local.node-exist.json');
  console.log('read from localConnectionOptions', localConnectionOptions)
}

let exClient = exist.createClient(localConnectionOptions);

const targetConfiguration = {
    target: '/db/apps/hsg-shell/',
    html5AsBinary: false
};

gulp.task('clean', function() {
    return del([
      'templates/**/*',
      'build/**/*',
      'resources/css/main.css',
      'resources/fonts/*'
    ]);
});

// fonts //

let fontPath = 'resources/fonts/';

gulp.task('fonts:copy', gulp.series(function () {
    return gulp.src([
            'bower_components/bootstrap-sass/assets/fonts/**/*',
            'bower_components/font-awesome/fonts/*'
        ])
        .pipe(gulp.dest('resources/fonts'))
}));

gulp.task('fonts:deploy', gulp.series('fonts:copy', function () {
    return gulp.src('resources/fonts/*', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
}));

// images //

/**
 * Image optimization task will *overwrite* an existing image
 * with its optimized version
 */
let imagePath = 'resources/images/**/*';
gulp.task('images:optimize', function () {
    return gulp.src('resources/images/*')
        .pipe(imagemin({optimizationLevel: 5}))
        .pipe(gulp.dest('resources/images'))
});

gulp.task('images:deploy', function () {
    return gulp.src('resources/images/*', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('images:watch', function () {
    gulp.watch('app/images/*', gulp.series('images:deploy'))
});

// scripts //

gulp.task('scripts:build', function () {
    // minified version of js is used in production only
    return gulp.src([
            'resources/scripts/app.js',
            'resources/scripts/metagrid.js'
        ])
        .pipe(uglify())
        .pipe(concat('app.min.js'))
        .pipe(gulp.dest('resources/scripts'))
});

gulp.task('scripts:concat', gulp.series('scripts:build', function () {
    return gulp.src([
            'bower_components/jquery/dist/jquery.min.js',
            'bower_components/bootstrap-sass/assets/javascripts/bootstrap.min.js',
            'resources/scripts/app.min.js'
        ])
      .pipe(concat('app.all.js'))
      .pipe(gulp.dest('resources/scripts'));
}));

gulp.task('scripts:deploy', gulp.series('scripts:concat', function () {
    return gulp.src('resources/scripts/*.js', {base: '.'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('scripts:watch', function () {
    gulp.watch('resources/scripts/*.js', gulp.series('scripts:deploy'))
});

// styles //
gulp.task('styles:build', gulp.series(function () {
    let compiler = sass({
        sourceMapEmbed: !PRODUCTION,
        sourceMapContents: !PRODUCTION,
        outputStyle: PRODUCTION ? 'compressed' : 'expanded'
    });

    compiler.on('error', sass.logError);
    return gulp.src('app/scss/main.scss')
        .pipe(compiler)
        .pipe(autoprefixer(AUTOPREFIXER_BROWSERS))
        .pipe(gulp.dest('resources/css'))
}));

gulp.task('styles:concat', gulp.series('styles:build', function () {
    return gulp.src([
            'resources/css/main.css',
            'resources/odd/compiled/frus.css'
        ])
      .pipe(concat('all.css'))
      .pipe(gulp.dest('resources/css'));
}));

gulp.task('styles:deploy', gulp.series('styles:build', 'styles:concat', function () {
    return gulp.src('resources/css/*.css', {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('styles:watch', function () {
    gulp.watch('app/scss/**/*.scss', gulp.series('styles:deploy'))
});

// pages //

let pagesPath = 'pages/**/*.xml';
gulp.task('pages:deploy', function () {
    return gulp.src(pagesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('pages:watch', function () {
    gulp.watch(pagesPath, gulp.series('pages:deploy'))
});

// modules //

let modulesPath = 'modules/*';
gulp.task('modules:deploy', function () {
    return gulp.src(modulesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('modules:watch', function () {
    gulp.watch(modulesPath, gulp.series('modules:deploy'))
});

// templates //

let templatesPath = 'templates/**/*.xml';

gulp.task('templates:build', function () {
    return gulp.src('app/' + templatesPath, {base: 'app/templates'})
        .pipe(preprocess({context: { PRODUCTION: PRODUCTION }}))
        .pipe(gulp.dest('templates'))
});

gulp.task('templates:deploy', gulp.series('templates:build', function () {
    return gulp.src(templatesPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('templates:watch', function () {
    gulp.watch(templatesPath, gulp.series('templates:deploy'))
});

// odd files //

let oddPath = 'resources/odd/**/*';
gulp.task('odd:deploy', function () {
    return gulp.src(oddPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('odd:watch', function () {
    gulp.watch(oddPath, gulp.series('odd:deploy'))
});

// files in project root //

let otherPath = '*{.xpr,.xqr,.xql,.xml,.xconf}';
gulp.task('other:deploy', function () {
    return gulp.src(otherPath, {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
});

gulp.task('other:watch', function () {
    gulp.watch(otherPath, gulp.series('other:deploy'))
});

// general //

gulp.task('build', gulp.series('clean', gulp.parallel('fonts:copy', 'images:optimize', 'styles:concat', 'templates:build', 'scripts:concat')));

gulp.task('deploy', gulp.series('build', function () {
    return gulp.src([
            'resources/**/*', // odd, styles, fonts, scripts
            templatesPath,
            pagesPath,
            modulesPath,
            imagePath,
            otherPath,
            fontPath
        ], {base: './'})
        .pipe(exClient.newer(targetConfiguration))
        .pipe(exClient.dest(targetConfiguration))
}));

gulp.task('watch', gulp.series('deploy', gulp.parallel('styles:watch', 'scripts:watch', 'images:watch', 'templates:watch', 'pages:watch', 'odd:watch', 'other:watch', 'modules:watch')));

gulp.task('default', gulp.series('build'));
