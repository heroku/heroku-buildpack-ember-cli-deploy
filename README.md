# heroku-buildpack-ember-cli-deploy
This buildpack was an experimental OSS project for running Ember.js fastboot applications on Heroku Dynos. It has since been *deprecated* and is *no longer supported*.

For an alternative for hosting Ember.js applications on Heroku, consider using the [`heroku/nodejs` buildpack](https://github.com/heroku/heroku-buildpack-nodejs) with the [`heroku/nginx` buildpack](https://github.com/heroku/heroku-buildpack-nginx).

## Intro

This is a [Heroku Buildpack](http://devcenter.heroku.com/articles/buildpacks) that handles the logic for building [Ember.js](http://emberjs.com/) and [ember-cli-fastboot](https://github.com/tildeio/ember-cli-fastboot) applications. It can leverage [ember-cli-deploy](http://ember-cli-deploy.com/) to allow you to customize your build process on Heroku. If ember-cli-deploy is not detected, the buildpack will run a standard `ember build --environment production`.

## Usage

This buildpack has a binary component, so it needs to be compiled beforehand. It's easiest just to use the buildpack with the prebuilt binary.

```
$ heroku buildpacks:set https://codon-buildpacks.s3.amazonaws.com/buildpacks/heroku/ember-cli-deploy.tgz
```

You'll need both `npm` and `node` setup before using this buildpack. I recommend checking out [heroku-buildpack-nodejs](https://github.com/heroku/heroku-buildpack-nodejs). In addition, if not using fastboot, you'll need a way to serve the assets. [heroku-buildpack-static](https://github.com/heroku/heroku-buildpack-static) can help there. When not using fastboot, the buildpack will generate a default [`static.json`](https://github.com/heroku/heroku-buildpack-static#configuration) for you.

An example of setting your app to advantage of all these pieces for a standard (non fastboot)  Ember.js application, you can do something like this:

```
$ heroku buildpacks:clear
$ heroku buildpacks:add heroku/nodejs
$ heroku buildpacks:add https://codon-buildpacks.s3.amazonaws.com/buildpacks/heroku/ember-cli-deploy.tgz
$ heroku buildpacks:add https://github.com/heroku/heroku-buildpack-static
```

Again, you probably want to be using the [emberjs buildpack](https://github.com/heroku/heroku-buildpack-emberjs).

## Contributing

The buildpack builds a CLI tool generically named, `buildpack` built on top of [mruby-cli](https://github.com/hone/mruby-cli). It resides in the `buildpack/` directory. `buildpack` is a CLI binary that has 3 subcommands that correspond to the [Buildpack API](https://devcenter.heroku.com/articles/buildpack-api):

* `detect`
* `compile`
* `release`

### Running Tests

First, you'll need the [mruby-cli prerequisites](https://github.com/hone/mruby-cli#prerequisites) setup. Once inside the `buildpack/` directory:

```
$ docker-compose run mtest && docker-compose run bintest
```
