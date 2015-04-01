$(document).pjax('a', '.wrap', 
  fragment: '.wrap', 
  timeout: 10000 
);


$('.wrap').on('pjax:start', ->
)

$('.wrap').on('pjax:end', ->
  $('.sidebar').perfectScrollbar()
  fill()
  $('title').html(title)
)

window.jQuery.fn.autosize = ->
  autosize this

$ ->
  $('.sidebar').perfectScrollbar()
  fill()
  
  $('body')
    .on 'click', '.create', ->
      if login isnt true
        action.showTip('You need to login') 
      else
        return false if typeof mod is 'undefined'
        if mod is 'edit'
          update()
        else
          create()
    .on 'click', '#preview-toggle', ->
      type = $(@).text()
      if type is 'Write'
        $(@).html('Preview')
        $('.preview-area').show()
        $('.editor').hide()
        markdown = $.trim($('.editor').val())
        $.post '/api/markdown', 
          markdown: markdown
          (data) ->
            html = if markdown then data.html else 'Nothing to preview'        
            $('.preview-area').html(html)
      else if type is 'Preview'
        $(@).html('Write')
        $('.preview-area').hide().html('Loading preview...')
        $('.editor').show()
    .on 'click', '.site-nav ul li a', ->
      $('.site-nav ul li a').not(@).removeClass('active')
      $(@).addClass('active')
    .on 'click', '.logout', (e) ->
      e.preventDefault()
      window.location.href = '/logout'
    .on 'click', '#settings-trigger', ->
      action.showModal('settings-modal')
    .on 'click', '.modal-overlay', ->
      $('.trigger').removeClass('active')
    .on 'click', '#save-password', ->
      password = $('#password').val()
      confirm = $('#password-confirm').val()
      currentPassword = $('#currentPassword').val()
      if password isnt confirm
        action.showTip 'The password you typed didn\'t match'
        return
      if not password or not confirm
        action.showTip 'Password invalid'
        return
      if password.length < 8
        action.showTip 'Your password is too weak, the length should be 8 to 16'
        return
      $.post '/settings/password', 
        currentPassword: currentPassword
        password: password,
        (data) ->
          if data._id
            action.closeModal()
            action.showTip 'You have successfully updated you profile!'
            $('input[type=password]').val('')
          else
            action.showTip data.detail          

  $('body').on 'focus change keydown keyup', '.editor', ->
    simpleStorage.set('editor', $('.editor').val()) if typeof mod isnt 'undefined' and mod is 'index'

  $('body').on 'click', '.clear', ->
    hidePreview()
    $('.editor').val('').attr('style','').focus()

  $('body').on 'click', '.delete', () ->
    if confirm 'Warning: This cannot be undone!'
      id = $(this).data('id')
      $.post '/save/remove',{id: id}, (data) ->
        window.location.href = '/'
    
  return

create = ->
  content = $.trim encodeURIComponent $('.editor').val()
  if content is ''
    action.showTip 'Please, I beg you to write something first...'
    return false
  $(@).attr('disabled', true)
  $.post '/save/new', {content: content}, (data) ->
    action.showTip 'You created a new snap!'
    $('.create').attr('disabled', false)
    setTimeout ->
      $.pjax
        url: '/p/' + data.random_id + '/edit'
        container: '.wrap'
      return
    , 2000
    return
    ###
    $('.new-text-block')
      .attr('href','/p/' + data.random_id)
      .html('http://snaply.me/p/' + data.random_id)
      .slideDown()
    ###

update = ->
  content = encodeURIComponent $('.editor').val()
  $.post '/save/update', {content: content, id: $('.editor').data('id')}, (data) ->
    action.showTip 'Updated!'
    prepCurrentFile()
    $('.new-text-block')
      .attr('href','/p/' + data.random_id)
      .html('http://snaply.me/p/' + data.random_id)
      .slideDown()

excuse = ->
  $.get 'https://api.githunt.io/programmingexcuses', (data) ->
    $('.editor').attr('placeholder', data)

fill = ->
  content = simpleStorage.get 'editor'
  return false if typeof mod is 'undefined'
  $('.editor').val(content).focus() if mod is 'index'
  excuse()
  $('.editor').autosize()

hidePreview = ->
  $('.preview-trigger').removeClass('active')
  $('.markdown-trigger').addClass('active')
  $('.editor').show()
  $('.preview-area').html('Loading preview…').hide()

prepCurrentFile = ->
  currentFile = $('.snap.active.loop-snap')
  if not currentFile.html()
    untitled = '<a class="snap current-snap" href="/">untitled</a>'
    $('.active-list').html(untitled) 
  id = currentFile.data('id')
  if $('.active-list').html() is ''
    currentFile.clone().prependTo('.active-list')
    $('.active-list').find('.active').removeClass('active')
  $('.active-list').find('.snap').each (index) ->
    if $(@).data('id') isnt id
      currentFile.clone().prependTo('.active-list')
      $('.active-list').find('.active').removeClass('active loop-snap').addClass('current-snap')
      return
