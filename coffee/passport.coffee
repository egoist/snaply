passport = require 'koa-passport'
GitHubStrategy = require('passport-github').Strategy
Model = require './models'
co = require 'co'

passport.use new GitHubStrategy(
  clientID: C[C.env].github.key
  clientSecret: C[C.env].github.secret
  callbackURL: C[C.env].github.url
, (accessToken, refreshToken, profile, done) ->

    co -> 
      user = 
        id: profile.id,
        displayName: profile.displayName,
        username: profile.username,
        provider: profile.provider,
        email: profile.emails[0].value,
        avatar: profile._json.avatar_url,
        last_login: new Date
      activeUser = yield Model.DB.users.where('id', profile.id).findOne()
      if typeof activeUser is 'undefined'
        activeUser = null

        #activeUser[key] = val for key, val of user
      if not activeUser
        newUser = new Model.DB.users(user)    
        yield newUser.save()
      else
        activeUser.set 'displayName', user.displayName
        activeUser.set 'username', user.username
        activeUser.set 'email', user.email
        activeUser.set 'last_login', new Date
        activeUser.set 'avatar', user.avatar
        yield activeUser.save()
      done null, user
      return
    return
)

passport.serializeUser (user, done) ->
  done null, user
  return
passport.deserializeUser (user, done) ->
  done null, user
  return

module.exports = passport