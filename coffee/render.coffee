###*
# Module dependencies.
###

views = require('co-views')
# setup views mapping .html
# to the swig template engine
module.exports = views(C.root + '/templates',
  map: html: 'swig'
  cache: 'memory')