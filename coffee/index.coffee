module.exports = (root) ->

  # Core dependency
  koa = require 'koa'
  app = koa()
  Router = require 'koa-router'
  json = require 'koa-json'
  path = require 'path'
  session = require 'koa-generic-session'
  staticCache = require 'koa-static-cache'
  redisStore = require 'koa-redis'
  cors = require 'koa-cors'
  logger = require 'koa-logger'

  # Load configs
  config = require './config'
  helpers = require './helpers'
  # Global variables
  global.C = config
  global.C.env = process.env.SNAP_ENV || C.env
  console.log C.env
  global.C.root = root
  global.H = helpers
  passport = require './passport'
  routes = require './routes'


  app.use logger()
  app.use cors()
  # App configs
  app.use staticCache(path.join(root, 'assets'), maxAge: 365 * 24 * 60 * 60)
  app.use json()
  app.keys = ['gdaf987G**(*^%', '&*YUG^RTFUF^GYU']
  app.use session(
    store: new redisStore(),
    prefix: 'snaply-'+C.env+':sess',
    key: 'snaply-'+C.env,
    cookie:
      path: '/',
      httpOnly: false,
      maxage: 86400 * 1000 * 365,
      rewrite: true,
      signed: true
  )
  app.use Router(app)
  app.use passport.initialize()
  app.use passport.session()

  authed = (next) -> 
    if this.req.isAuthenticated()
      yield next;
    else 
      this.session.returnTo = this.session.returnTo || this.req.url;
      this.redirect '/'
  

  # Routes configs
  router = new Router()
  router.get '/', routes.index
  router.get '/p/:id', routes.p
  router.get '/p/:id/raw', routes.p_raw
  router.get '/p/:id/html', routes.p_html
  router.get '/p/:id/edit', authed, routes.edit
  router.post '/api/markdown', routes.markdown
  router.post '/save/remove', authed, routes.remove
  router.post '/save/new', routes.create
  router.post '/save/update', routes.update
  router.get '/auth/github', passport.authenticate('github',
    scope: ['user:email']
  )
  router.get '/auth/github/callback',
    passport.authenticate 'github', 
      successRedirect: '/',
      failureRedirect: '/'

  router.get '/app', authed, ->
    this.body = yield this.req.user
  router.get '/logout', (next) ->
    this.logout()
    this.redirect '/'
    yield next

  app.use router.middleware()

  # Listen on port
  app.listen config.port

  console.log config.site.name + ' is singing at http://localhost:' + config.port