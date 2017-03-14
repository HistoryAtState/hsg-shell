# hsg-shell

## Prerequisites

You need to have *ant*, *git* and *nodeJS* (version 4 or 5) installed.

### For Mac OS X

With **[homebrew](http://brew.sh#install)** installed, do

    brew update && brew upgrade
    brew install ant git node@4

### Install global node packages

After node is installed just run

    npm install -g gulp bower

## Setup

1. Clone the repository

    `git clone https://github.com/HistoryAtState/hsg-shell.git`

1. Install dependencies for the front-end and automation tasks (`npm` & `bower`),
    Build and copy javascripts, fonts, css and images into the *resources* folder (`gulp`) and
    generate the *.xar-package* inside the *build* directory

    `ant`

1. Switch to the exist Dashboard

1. Install the package `build/hsg-shell-x.y.xar` with the Package Manager

1. Click on the *history.state.gov* icon on the eXist Dashboard

## Update

To create an up-to-date build package to install in eXistDB, this should do

    git pull && ant

## Optional: Install bootstrap documentation

- Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
- Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
- See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
- In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/

## Development

`gulp build` builds the resource folder with fonts, optimized images, scripts and compiled styles

`gulp deploy` sends the resource folder to a local existDB

`gulp watch` will upload the build files whenever a source file changes

**NOTE:** For the deploy and watch task you may have to edit the DB credentials in `gulpfile.js`.

## Build

`ant` builds XAR file after running npm install bower install and gulp (build)

### Production

If `NODE_ENV` environment variable is set to **production** the XAR is build with
minified and concatenated styles and scripts. This build will then include
google-analytics and DAP tracking.

`NODE_ENV=production ant` for a single test

`export NODE_ENV` in the login script on a production server
