# hsg-shell

## Prerequisites

You need to have *ant*, *git* and *nodeJS* installed.
*[gulp](http://gulpjs.com/)* needs to be installed globally.

#### For Mac OS X

With **[homebrew](http://brew.sh#install)** installed, do

    brew update && brew upgrade
    brew install ant git node

#### Install global node packages

After node is installed just run

    npm install -g gulp bower

## Setup

1. Clone the repository

    `git clone https://github.com/eXistSolutions/hsg-shell.git`

1. Install dependencies for the front-end and automation tasks

    `npm install && bower install`

1. Build and copy javascripts, fonts, css and images into the *resources* folder

    `gulp`

1. Generate the *.xar-package* inside the *build* directory

    `ant`

1. Switch to the exist Dashboard

1. Install the package `build/hsg-shell-x.y.xar` with the Package Manager

1. Click on the *history.state.gov* icon on the eXist Dashboard

## Update

To create an up-to-date build package to install in eXistDB, this should do

    npm run update

It will just run four of the previous steps one after another (`git pull && npm install && gulp && ant`).

## Optional: Install bootstrap documentation

- Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
- Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
- See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
- In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/

## Development

`gulp build` builds the resource folder with fonts, optimized images, vendor javascript libraries and compiled styles

`gulp deploy` sends the resource folder to a local existDB - you may have to edit the credentials in gulpfile.js

`gulp watch` will upload the build files whenever the SCSS or JS source files change