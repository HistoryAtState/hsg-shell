# hsg-shell

For *hsg-project* users, all instructions are at [github.com/HistoryAtState/hsg-project/wiki/Setup](https://github.com/HistoryAtState/hsg-project/wiki/Setup).

## 1. Build

### Prerequisites

You need to have *ant*, *git*, *asdf* and *nodeJS* installed.

1. You will need to have `asdf` installed:
   Install [asdf](https://asdf-vm.com/guide/getting-started.html).
2. If you have already used asdf before and have various ant / node versions already installed, you can skip this. Now just make sure to use the project's required nodejs / ant version is running 

        asdf plugin add nodejs
        asdf install nodejs 18.18.2
        asdf global nodejs 18.18.2
   
        asdf plugin add ant
        asdf install ant 1.10.13
        asdf global ant 1.10.13

4. Install gulp

        npm install -g gulp

   The project's gulp file depends on `gulp 4` (or higher) syntax, so make sure in the next step, that you'll have gulp 4.x running.

### Installation

1. Clone the repository

        git clone https://github.com/HistoryAtState/hsg-shell.git
        cd hsg-shell

3. Build the application package
   For a ready-to-install xar file, run the command

        ant

   * `ant` will build a XAR file after automatically running npm start and gulp (build).
   * At least on macOS, the asdf shim for `ant` produces an error if the command has no flags. As a workaround, use `ant -Dfoo=bar`.

4. Install the package `build/hsg-shell.xar` with the Package Manager or, as described below, xst

5. Click on the *history.state.gov* icon on the eXist Dashboard

#### Troubleshooting `npm` Problems

If you encounter errors while running `npm start` (this is called when building the xar file by running `ant`), or during `npm install`, please delete file `package-lock.json`, delete the entire `node_modules` folder and finally `npm start` again.
This should install all node modules with the required node version.

A new `package-lock.json` file will be created, which should be added to version control.  

### Check currently installed versions

1. node: `node -v` => Should output `v18.18.2`
2. npm: `npm -v` => Should output at least `v9.8.1`
3. gulp: `npx gulp -v` => Should output at least `CLI version: 2.3.0, Local version: 4.0.2`


### Production

If `HSG_ENV` environment variable is set to **production** the XAR is build with
minified and concatenated styles and scripts. This build will then include
google-analytics and DAP tracking.

`HSG_ENV=production ant` for a single test

`export HSG_ENV=production` in the login script on a production server

## 2. Update

To create an up-to-date build package to install in eXist-db, this should do

    git pull && ant

### Optional: Install bootstrap documentation

* Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
* Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
* See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
* In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/

## 3. Development

Use the [hsg-project Docker Container](https://hub.docker.com/r/joewiz/hsg-project/tags). Make sure you have [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and docker is running.

Download the latest Docker image of hsg-project 

```
docker pull joewiz/hsg-project:latest
```

Start the hsg-project Docker Container 

```
docker run -p 8080:8080 joewiz/hsg-project:latest
```

One the docker container is started point your browser to http://localhost:8080 to verify everything is working

### Deploy local changes via `xst` into a local eXist-db
Install [`xst`](https://github.com/eXist-db/xst) by executing `npm install --global @existdb/xst`. 

Create a file called `.env` in the root folder of this project with the following content: 

```
EXISTDB_USER=admin
EXISTDB_PASS=
EXISTDB_SERVER=http://localhost:8080
```

Run `ant` to create the XAR file and afterwards `xst package install build/hsg-shell.xar` to install the created XAR file in your local database. 

### Deploy local changes via `existdb-vscode` into a local eXist-db
Make sure you have [Visual Studio Code](https://code.visualstudio.com/) installed and open it. In Visual Studio Code open `View > Extensions` from the menu and make sure the `existdb-vscode` extension is installed. 

Open `.existdb.json` in Visual Studio Code and click "save". This opens a dialog with the following text 

```
This package requires a small support app to be installed on the eXistdb server. Do you want to install it?
```

Click on the "Install" button. 

Open the "Command Palette" in Visual Studio Code either via menu ( `View > Command Palette`) or keyboard shortcut `Shift + Command + P`for Mac or `Ctrl + Shift + P`  on Windows and Linux and type `exist-db: Reconnect to Server` followed by `exist-db: Control folder syncronizationt to database` and confirm the popup `hsg-shell: start syncronization`. To stop the syncronization simply run `exist-db: Control folder syncronizationt to database` again, if the sync is still active the popup will now say `hsg-shell stop syncronization`. If the syncronization is active every file you store in Visual Studio Code will always be synced into the database. 

To deploy a full XAR file make sure you build the latest version by callling `ant`, open up the Command Palette and run `exist-db: Deploy package to the database`. In the following popup select the XAR file to be deployed and confirm by pressing Return. This will install the XAR file in your local eXist-db. 
 
## 4. Web Tests

Verify you have a local hsg-project running at localhost:8080/exist/apps/hsg-shell. See the Docker section for easy installation.  

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

#### 2. Optional: Edit configuration

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
npm test
```

Use `npx` to execute different test suites 

```bash
npx wdio wdio.conf.js --suite <name-of-the-testsuite>
```
for example (runs all development environment test that have been listed in the wdio configuration in `suites: {prod : ...}`):

```bash
npx wdio wdio.conf.js --suite test-prod
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
"test": "./node_modules/.bin/wdio wdio.conf.js --suite test-prod"
```
and run this command with
```shell
npm run-script test-prod
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
