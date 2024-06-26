# hsg-shell

For *hsg-project* users, all instructions are at [github.com/HistoryAtState/hsg-project/wiki/Setup](https://github.com/HistoryAtState/hsg-project/wiki/Setup).

## 1. Build

### Prerequisites

You need to have *ant*, *git*, *nvm* and *nodeJS* installed.

1. You will need to have `nvm` installed:
   Install [nvm](https://github.com/nvm-sh/nvm) and follow the [installation instructions](https://github.com/nvm-sh/nvm#installing-and-updating).
2. Make sure to install nvm with a specific node version (see https://github.com/nvm-sh/nvm/blob/master/README.md#usage)

        `nvm install 18.18.2`

3. If you have already used nvm before and have various node versions already installed, you can skip 1). Now just make sure to use the project's required node version by running 

        `nvm use 18`

This command will check the local node settings in the project's `.nvmrc` file and switch to this node version only for this project.  

4. Install (or update to) the latest `npm` version with:

        `npm install -g npm`

5. Install gulp

        `npm install -g gulp`

   The project's gulp file depends on `gulp 4` (or higher) syntax, so make sure in the next step, that you'll have gulp 4.x running.

#### Troubleshooting `npm` Problems

When you encounter errors while running `npm start` (this is called when building the xar file by running `ant`), or during `npm install`, please delete file `package-lock.json`, delete the entire `node_modules` folder, run `nvm use` and finally `npm start` again.
This should install all node modules with the required node version.   
A new `package-lock.json` file will be created, which should be added to version control.  

### Installation

1. Clone the repository

        git clone https://github.com/HistoryAtState/hsg-shell.git

1. Build the application package
   For a ready-to-install xar file, run the command

    ant

   * The included subtask `ant prepare` will check your local paths to all the specific `npm` and `gulp` binaries within the `nvm` folder and create a local build properties file for you.
   * `ant node` will install the appropriate node version for this project, which is specified in the `.nvmrc` file, currently `v14.19.3`.
   * `ant` will build a XAR file after automatically running npm install bower install and gulp (build).

2. Install the package `build/hsg-shell.xar` with the Package Manager

3. Click on the *history.state.gov* icon on the eXist Dashboard

### How to update Node and other build & development tools

In order to build a xar package of the app with `ant` and to run scripts, that will build the app files like ie. minified css, js, you'll need to install `node.js`, `npm` and `gulp` in certain versions, that will be specified in this projects `package.json` and `package-lock.json` (for dependency locks).

### Update node and npm versions

1. Install [nvm](https://github.com/nvm-sh/nvm) and follow the [installation instructions](https://github.com/nvm-sh/nvm#installing-and-updating).
1. Check your current node version with `node --version`, it should be `v17.6.0` now (this step can be skipped once the local build file has been created by running `ant`).
1. Install (or update to) the latest `npm` version with `npm install -g npm`.
1. Install bower `npm install -g bower`.
1. Install gulp `npm install -g gulp`. The project's gulp file depends on `gulp 4` (or higher) syntax, so make sure in the next step, that you'll have gulp 4.x running.
1. Check the paths, where your node, npm and gulp have been installed (depends on OS) by running `which node`,
   `which npm`, `which gulp` (this step can be skipped once the local build file has been created by running `ant prepare`).
1. Look for file `build.properties.local.example.xml`, copy it, rename it to `build.properties.local.xml` and insert the current paths you just got by running the "which" commands. This file is necessary for pointing the ant task runner to the necessary build tools (this step can be skipped once the local build file has been created by running `ant prepare`).
1. Install the node packages (listed in file `package.json`) by running `npm install` .
1. If npm errors occur, try fix it either by running `npm install` again, or `npm update`, or by
   deleting the entire `node_modules` folder from the project and then running `npm install` once again.
1. Last, you may have to edit the credentials in file `local.node-exist.json` which is needed for configure the automated deployment of files from your local HSG-Shell project to your local existdb. The defaults in this file will generally apply here, unless you have modified the credentials elsewhere.

### Finally check currently installed versions

1. node: `node -v` => Should output `v18.18.2`
2. npm: `npm -v` => Should output at least `v8.5.0`
3. gulp: `npx gulp -v` => Should output at least `CLI version: 2.2.0, Local version: 4.0.2`

Now, with a running eXist-db you're ready to run either `ant`, or `gulp` to test if your update was successful.

### Production

If `HSG_ENV` environment variable is set to **production** the XAR is build with
minified and concatenated styles and scripts. This build will then include
google-analytics and DAP tracking.

`HSG_ENV=production ant` for a single test

`export HSG_ENV` in the login script on a production server

## 2. Update

To create an up-to-date build package to install in eXist-db, this should do

    git pull && ant prepare && ant node && ant

### Optional: Install bootstrap documentation

* Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
* Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
* See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
* In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/

## 3. Development

`npx gulp build` builds the resource folder with fonts, optimized images, scripts and compiled styles

`npx gulp deploy` sends the resource folder to a local existDB

`npx gulp watch` will upload the build files whenever a source file changes.

**NOTE:** For the deploy and watch task you may have to edit the DB credentials in `gulpfile.js`.

## 4. Web Tests

### How to run local web tests

#### 1. Install Chrome

Make sure you have Google Chrome >= 110 and all required node_modules installed (`npm install`).

##### Troubleshooting Chromedriver Problems

If you have problems with installing or running Chromedriver, have a look at these resources: [webdriver.io/docs/wdio-chromedriver-service.html](https://webdriver.io/docs/wdio-chromedriver-service.html), [stackoverflow](https://stackoverflow.com/questions/54940853/chrome-version-must-be-between-71-and-75-error-after-updating-to-chromedriver-2)

It might be helpful to run

```shell
npm install chromedriver --detect_chromedriver_version
```

All available chromedriver versions are listed here: [https://chromedriver.storage.googleapis.com/](https://chromedriver.storage.googleapis.com/).

If your current Chrome version doesn't match the required one.
This command will check the required version and install a suitable Chromedriver for you.

Note: If you are using an Apple M1 computer, the filename for chromedriver has been changed by Chrome between version 105 and 106 [See fix for node_chromedriver: https://github.com/giggio/node-chromedriver/pull/386/](https://github.com/giggio/node-chromedriver/pull/386/commits/7bc8dc46583ca484ca17707d9d98f8a1f98b9be4#).
When running this project's ant script on an M1 with a Chrome version <=105, you should either update Chrome to 110 like defined in file `package.json`, or change the chromedriver version to your current Chrome version to match the expected chromedriver filename.

#### 2. Edit configuration

* Edit the path to where your local Chrome binary is installed in the **web test configuration** **`wdio.conf.js`** at line:
    ```javascript
    process.env.WDIO_CHROME_BINARY = process.env.WDIO_CHROME_BINARY || 'path-to-your-local-binary'
    ```
* Optional: Edit which test files or suites you would like to run.
  Here is the part where to define the test suites:
    ```
      suites: {
        dev: [
          './tests/specs/**/dev_*.js'
        ],
        prod: [
          './tests/specs/**/prod_*.js'
        ]
      }
    ```

#### 3. Run the web test

Basic syntax of starting an entire test suite is
```bash
npx wdio wdio.conf.js --suite <name-of-the-testsuite>
```
for example (runs all development environment test that have been listed in the wdio configuration in `suites: {dev : ...}`):

```bash
npx wdio wdio.conf.js --suite dev
```

and for a single test it is
```bash
npx wdio wdio.conf.js --spec path-to-the-testspec
```
for example:
```bash
npx wdio wdio.conf.js --spec tests/specs/error/prod_404.spec.js
```

In addition, you can define running the test commands in `package.json`
within the `scripts` key, for example:
```json
"test-dev": "wdio wdio.conf.js --suite dev"
```
and run this command with
```shell
npm run-script test-dev
```

This test runs in "headless" mode. It means the test will run in the background without opening a browser window.
If you want to observe all actions in the web test in a browser, just comment out the `headless` argument in the `wdio.conf.js`:

```
chromeOptions: {
  args: [
  //'headless',
    'disable-gpu',
    '--window-size=1280,1024',
    'ignore-certificate-errors',
    'ignore-urlfetcher-cert-requests'
  ],
  binary: process.env.WDIO_CHROME_BINARY
},
```

#### 4. Further documentation

This web test is configured to use the framework `Mocha` with `Chai` and activated Chai plugin `assert` (`global.assert = chai.assert;`) for assertions.

Have a look at the documentation:

* General overview about "webdriver.io": [webdriver.io/docs/gettingstarted](https://webdriver.io/docs/gettingstarted.html)
* Webdriver.io functions: [webdriver.io/docs/api](https://webdriver.io/docs/api.html)
* List of all functions in the Chai Assertion library: [chaijs.com/api/assert](https://www.chaijs.com/api/assert/)
* Overview about mocha.js: [mochajs.org](https://mochajs.org/)

## Release

Releases for this data package are automated. Any commit to the `master` branch will trigger the release automation.

All commit message must conform to [Conventional Commit Messages](https://www.conventionalcommits.org/en/v1.0.0/) to determine semantic versioning of releases, please adhere to these conventions, like so:


| Commit message  | Release type |
|-----------------|--------------|
| `fix(pencil): stop graphite breaking when too much pressure applied` | Patch Release |
| `feat(pencil): add 'graphiteWidth' option` | ~~Minor~~ Feature Release |
| `perf(pencil): remove graphiteWidth option`<br/><br/>`BREAKING CHANGE: The graphiteWidth option has been removed.`<br/>`The default graphite width of 10mm is always used for performance reasons.` | ~~Major~~ Breaking Release |

When opening PRs commit messages are checked using commitlint.