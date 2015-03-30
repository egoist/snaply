helpers = module.exports = {}

helpers.css = (filename) ->
  '<link rel="stylesheet" href="/css/' + filename + '.css?v='+require('../package').version+'">'

helpers.font = (font) ->
  '<link rel="stylesheet" href="/fonts/' + font + '/style.css">'

helpers.js = (filename) ->
  '<script src="/js/' + filename + '.js?v='+require('../package').version+'"></script>'

helpers.string = (length) ->
  randomstring = require 'randomstring'
  randomstring.generate length

helpers.escapeHtml = (text) ->
  require('escape-html')(text)

helpers.title = (text, length) ->
  length = length || 40
  text = text.split('\n')[0]
  sub text, length

helpers.count = (text) ->
  require('word-count')(text)

helpers.stripTags = (text) -> 
  text.replace(/(<([^>]+)>)/ig,"")

helpers.xss = (text) ->
  xss = require('xss');
  xss.whiteList['pre'] = ['class', 'style','id']
  xss.whiteList['p'] = ['class', 'style','id']
  xss.whiteList['span'] = ['class', 'style','id']
  xss.whiteList['div'] = ['class', 'style','id']
  xss.whiteList['img'] = ['class', 'src']
  xss.whiteList['i'] = ['class']
  xss.whiteList['ul'] = ['class']
  xss.whiteList['li'] = ['class']
  xss.whiteList['input'] = ['type', 'class', 'disabled', 'id', 'checked']
  xss text

sub = (str, n) ->
  r = /[^\x00-\xff]/g
  if str.replace(r, 'mm').length <= n
    return str
  m = Math.floor(n / 2)
  i = m
  while i < str.length
    if str.substr(0, i).replace(r, 'mm').length >= n
      return str.substr(0, i) # + '...'
    i++
  str

helpers.md = (text) ->
  marked = require 'marked'
  cheerio = require 'cheerio'
  renderer = new marked.Renderer()
  complete = '<input type="checkbox" class="task-list-item-checkbox" checked="" disabled="">'
  uncomplete = '<input type="checkbox" class="task-list-item-checkbox" disabled="">'
  renderer.list = (body, ordered) ->
    type = if ordered then 'ol' else 'ul'
    startType = type
    $ = cheerio.load(body)

    startType = type + ' class="task-list-items"' if $('li').find('input').length > 0
    '<' + startType + '>\n' + body + '</' + type + '>\n'
  renderer.listitem = (text) ->
    if /^\s*\[[x ]\]\s*/.test(text)
      checkbox = if /^\s*\[[xX]\]\s*/.test(text) then complete else uncomplete
      text = text.replace(/^\s*\[ \]\s*/, checkbox).replace(/^\s*\[x\]\s*/, checkbox)
      '<li class="task-list-item">' + text + '</li>'
    else
      '<li>' + text + '</li>'
  marked.setOptions
    renderer: renderer
    gfm: true
    tables: true
    breaks: false
    pedantic: false
    sanitize: true
    smartLists: true
    smartypants: false
    highlight: (code) ->
      require('highlight.js').highlightAuto(code).value
  marked(text)