Model = require './models'
parse = require 'co-body'
emoji = require 'emojione'
bcrypt = require 'co-bcryptjs'

routes = module.exports = {}

render = require './render'

routes.index = ->
  user = this.req.user
  if typeof user isnt 'undefined'
    snaps = yield Model.DB.snaps.where('uid', user.id).sort(
      created_at: -1
    ).find()
    for snap, i in snaps
      snaps[i] = snap.attributes
      snaps[i].title = H.title H.stripTags require('marked')(snaps[i].content)
  this.body = yield render 'index', 
    user: user
    snaps: snaps
    active: 'home'

routes.text = ->
  this.body = yield render 'text', bg:''

routes.p = ->
  moment = require 'moment'
  id = this.params.id
  user = this.req.user
  active = if id is 'KPIRnKORlet' then 'about' else ''
  snap = yield Model.DB.snaps.where('random_id', id).findOne() 
  if typeof snap is 'undefined'
    this.body = 'not found'
    return
  snap = snap.attributes
  author = yield Model.DB.users.where('id', snap.uid).findOne()
  author = author.attributes
  snap.content = H.xss emoji.toImage H.md snap.content
  snap.title = H.title H.stripTags snap.content
  timestamp = Date.parse(snap.created_at) / 1000;
  snap.timeAgo = moment(timestamp, 'X').fromNow();
  snap.count = H.count snap.content
  if typeof user isnt 'undefined'
    snaps = yield Model.DB.snaps.where('uid', user.id).sort(
      created_at: -1
    ).find()
    for s, i in snaps
      snaps[i] = s.attributes
      snaps[i].title = H.title H.stripTags require('marked')(snaps[i].content)
  this.body = yield  render 'p', 
    user: user
    snap: snap
    snaps: snaps
    author: author
    active: active

routes.markdown = ->
  post = yield parse this, limit: '8000kb'
  markdown = post.markdown
  html = H.xss emoji.toImage H.md markdown
  # todo: count length
  output = 
    html: html
  this.body = output

routes.p_raw = ->
  id = this.params.id
  snap = yield Model.DB.snaps.where('random_id', id).findOne()
  if typeof snap is 'undefined'
    this.body = 'not found'
    return
  snap = snap.attributes
  this.type = 'text/x-markdown'
  this.body = snap.content

routes.p_html = ->
  id = this.params.id
  snap = yield Model.DB.snaps.where('random_id', id).findOne()
  if typeof snap is 'undefined'
    this.body = 'not found'
    return
  snap = snap.attributes
  this.type = 'text/plain'
  this.body = require('marked')(snap.content)

routes.create = ->
  post = yield parse this, limit: '8000kb'
  post.content = decodeURIComponent post.content
  random_id = H.string 11
  snap = new Model.DB.snaps (
    content: post.content,
    uid: this.req.user.id
    random_id: random_id
    type: 'text'
  )
  snap = yield snap.save()
  this.body = snap

routes.update = ->
  post = yield parse this, limit: '8000kb'
  post.content = decodeURIComponent post.content
  id = post.id
  user = this.req.user
  snap = yield Model.DB.snaps.where('random_id', id).findOne()
  login = yield Model.DB.users.where('id', user.id).findOne()
  recent_updated = login.attributes.recent_updated
  updated =
    id: id 
    title: H.title H.stripTags post.content
  if not recent_updated 
    recent_updated = []
    recent_updated[0] = updated
    login.set 'recent_updated', recent_updated
    yield login.save()
  else
    listed = false
    for r, i in recent_updated
      if r.id is id
        listed = true
        break
    if not listed
      if recent_updated.length is 5
        recent_updated.splice(0, 1)
      recent_updated[recent_updated.length] = updated
      login.set 'recent_updated', recent_updated
      yield login.save()
  if this.req.user.id isnt snap.attributes.uid
    this.redirect('/') 
    return
  snap.set 'content', post.content
  snap = yield snap.save()
  this.body = snap

routes.remove = ->
  post = yield parse this
  id = post.id
  snap = yield Model.DB.snaps.where('_id', id).findOne()
  #return if this.req.user.id isnt snap.uid
  snap = yield snap.remove()
  this.body = snap

routes.edit = ->
  id = this.params.id
  user = this.req.user
  snap = yield Model.DB.snaps.where('random_id', id).findOne()
  snap = snap.attributes
  if this.req.user.id isnt snap.uid
    this.redirect('/') 
    return
  snaps = yield Model.DB.snaps.where('uid', user.id).sort(
      created_at: -1
    ).find()
  for s, i in snaps
    snaps[i] = s.attributes
    snaps[i].title = H.title H.stripTags require('marked')(snaps[i].content)
  this.body = yield render 'index', 
    user: user 
    snap: snap
    snaps: snaps

routes.password = ->
  post = yield parse this
  currentPassword = post.currentPassword
  password = post.password
  salt = yield bcrypt.genSalt(10)
  hash = yield bcrypt.hash(password, salt)
  user = yield Model.DB.users.where('id', this.req.user.id).findOne()
  if currentPassword
    checkPassword = yield bcrypt.compare(currentPassword, user.attributes.password)
    if user.attributes.password and not checkPassword
      this.body = 
        status: 'bad'
        detail: 'Wrong password'
      return
  user.set('password', hash)
  user = yield user.save()
  this.body = user
