Mongorito = require 'mongorito'
Model = Mongorito.Model
Mongorito.connect 'localhost/snaply'

models = module.exports = {}

Snaps = Model.extend({
  collection: 'snaps'
})

Users = Model.extend({
  collection: 'users'
})

models.DB = {
  snaps: Snaps,
  users: Users
}