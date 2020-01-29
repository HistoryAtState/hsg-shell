# hsg-shell

## Prerequisites

You need to have *ant*, *git* and *nodeJS* (version 10.0.0 or higher) installed.

### hsg-project users

All instructions are at https://github.com/HistoryAtState/hsg-project/wiki/Setup.

### For other macOS users

With **[homebrew](http://brew.sh#install)** installed, run:

    brew update && brew upgrade
    brew install ant git node@10

And follow homebrew's instructions to ensure that node 10's executables are 
run:

> If you need to have node@10 first in your PATH run:

    echo 'export PATH="/usr/local/opt/node@10/bin:$PATH"' >> ~/.bash_profile

Then:

    source ~/.bash_profile

### Install global node packages

After node is installed just run

    npm install -g gulp bower

## Setup

1. Clone the repository

        git clone https://github.com/HistoryAtState/hsg-shell.git

1. Build the application package

        ant

1. Switch to the eXist Dashboard

1. Install the package `build/hsg-shell-x.y.z.xar` with the Package Manager

1. Click on the *history.state.gov* icon on the eXist Dashboard

## Update

To create an up-to-date build package to install in eXist-db, this should do

    git pull && ant

## Optional: Install bootstrap documentation

- Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
- Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
- See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
- In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/

## Development

`gulp build` builds the resource folder with fonts, optimized images, scripts and compiled styles

`gulp deploy` sends the resource folder to a local existDB

`gulp watch` will upload the build files whenever a source file changes.

**NOTE:** For the deploy and watch task you may have to edit the DB credentials in `gulpfile.js`.

## Build

`ant` 

1. Single `xar` file: This will build a XAR file after running npm install bower install and gulp (build).  
    ```shell
    ant
    ```

2. DEV environment:   
   This will build XAR files for development servers after running npm install bower install and gulp (build).  
   The replication triggers for the producer server are enabled in  `collection.xconf` and point to the dev server's replication service IP.
    ```shell
    ant xar-dev
    ```

3. PROD environment:  
    This will build XAR files for production servers after running npm install bower install and gulp (build) 
    Same as in 2. but for PROD destination
    ```shell
    ant xar-prod
    ```

## How to update Node and other build & development tools

In order to build a xar package of the app with `ant` and to run scripts, that will build the app files like ie. minified css, js, you'll need to install `node.js`, `npm` and `gulp` in certain versions, that will be specified in this projects `package.json` and `npm-shrinkwrap.json` (for dependency locks).  

### Update node and npm versions

1. Update your system to `node v10.0.0` either via using [nvm](https://github.com/nvm-sh/nvm), or directly from the [node website](https://nodejs.org/en/).
1. Check your current node version with `node --version`, it should be `v10.0.0` now.
1. Install (or update to) the latest `npm` version with `npm install -g npm`.
1. Install bower `npm install -g bower`.
1. Install gulp `npm install -g gulp`. The project's gulp file depends on `gulp 4` (or higher) syntax, so make sure in the next step, that you'll have gulp 4.x running.
1. Check the paths, where your node, npm and gulp have been installed (depends on OS) by running `which node`,
`which npm`, `which gulp`.
1. Look for file `example.local.build.properties`, copy it, rename it to `local.build.properties` and insert the current paths you just got by running the "which" commands. This file is necessary for pointing the ant task runner to the necessary build tools.
1. Install the node packages (listed in file `package.json`) by running `npm install` .
1. If npm errors occur, try fix it either by running `npm update`, or by
deleting the entire `node_modules` folder from the project and then running `npm install` once again.
1. Last, you may have to edit the credentials in file `local.node-exist.json` which is needed for configure the automated deployment of files from your local HSG-Shell project to your local existdb. The defaults in this file will generally apply here, unless you have modified the credentials elsewhere.

### Finally check currently installed versions
1. node: `node -v` => Should output `v10.0.0`
2. npm: `npm -v` => Should output at least `v6.9.0`
3. gulp: `gulp -v` => Should output at least `CLI version: 2.2.0, Local version: 4.0.2`

Now, with a running eXist-db you're ready to run either `ant` or `gulp` to test if your update was successful.

### Production

If `NODE_ENV` environment variable is set to **production** the XAR is build with
minified and concatenated styles and scripts. This build will then include
google-analytics and DAP tracking.

`NODE_ENV=production ant` for a single test

`export NODE_ENV` in the login script on a production server

### Web Tests

#### How to run local web tests

##### 1. Install Chrome
Make sure you have Google Chrome >= 79 and all required node_modules installed (`npm install`).
If you have problems with installing or running Chromedriver, have a look at these resources: [webdriver.io/docs/wdio-chromedriver-service.html](https://webdriver.io/docs/wdio-chromedriver-service.html), [stackoverflow](https://stackoverflow.com/questions/54940853/chrome-version-must-be-between-71-and-75-error-after-updating-to-chromedriver-2)

##### 2. Edit configuration 
* Edit the path to where your local Chrome binary is installed in the web test configuration `wdio.conf.js` at line: 
    ```javascript
    process.env.WDIO_CHROME_BINARY = process.env.WDIO_CHROME_BINARY || 'path-to-your-local-binary'
    ```
* Optional: Edit which test files or suites you would like to run.
  Here is the part here to define the test suites:
    ```json
      suites: {
        dev: [
          './tests/specs/**/dev_*.js'
        ],
        prod: [
          './tests/specs/**/prod_*.js'
        ]
      }
    ```

##### 3. Run the web test
Basic syntax of starting an entire test suite is 
```bash
node_modules/.bin/wdio wdio.conf.js --suite name-of-the-testsuite
```
for example: 
```bash
node_modules/.bin/wdio wdio.conf.js --suite dev
```

and for a single test it is
```bash
node_modules/.bin/wdio wdio.conf.js --spec path-to-the-testspec
```
for example: 
```bash
node_modules/.bin/wdio wdio.conf.js --spec tests/specs/error/prod_404.spec.js
```

In addition, you can define running the test commands in `package.json`
within the `scripts` key, for example:
```json
"test-dev": "./node_modules/.bin/wdio wdio.conf.js --suite dev"
```
and run this command with
```shell
npm run-script test-dev
```
