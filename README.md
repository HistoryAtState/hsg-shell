# hsg-shell

## Setup

- Clone the repository
- For Mac OS X:
  - Install [homebrew](http://brew.sh#install), or if already installed: `brew update && brew upgrade`
  - Install required tools part 1 (ant, git, npm, and ruby): `brew install ant git npm ruby`
  - Install required tools part 2 ([bower](http://bower.io/) and [grunt](http://gruntjs.com/)): `npm install -g bower grunt-cli`
- Run `bower install` to install the dependencies defined in the project's `bower.json` file
- Run `ant` to generate the `.xar` file inside the `build` directory
- Install the `build/hsg-shell-x.y.xar` via the eXist Dashboard Package Manager
- Click on the "history.state.gov" icon from the eXist Dashboard

## Optional: Install bootstrap documentation

- Clone [bootstrap](https://github.com/twbs/bootstrap) via `https://github.com/twbs/bootstrap.git`
- Install [Jekyll](http://jekyllrb.com/docs/installation/) to be able to view bootstrap docs locally: `gem install jekyll`
- See this tip for working around [jekyll installation errors](https://github.com/wayneeseguin/rvm/issues/2689#issuecomment-52753818) `brew unlink libyaml && brew link libyaml`
- In the bootstrap clone directory, run `jekyll serve`, then view bootstrap documentation at http://localhost:9001/
