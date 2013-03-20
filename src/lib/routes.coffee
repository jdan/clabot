'use strict'

_ = require 'lodash'

comment     = require './comment'

exports.notify = (req, res) ->
  options = req.clabotOptions
  payload = JSON.parse req.body.payload

  number = payload.number
  repo   = payload.repository.name
  sender = payload.sender.login
  user   = payload.repository.owner.login

  handleComment = (contributors) ->
    signed = _.contains contributors, sender

    commentData =
      user  : user
      repo  : repo
      number: number
      body  : comment.getCommentBody signed,
        options.templates,
        _.extend options.templateData, { sender, payload }

    comment.send options.token, commentData, (err, data) ->
      if err
        console.log   JSON.parse err
        console.log   'Fatal Error: GitHub refused to comment'
        res.send 500, 'Fatal Error: GitHub refused to comment'
      else
        console.log "Comment created: #{payload.pull_request._links.html.href}"
        res.send 200,

  if payload.action is 'opened'

    if _.isFunction options.getContributors
      options.getContributors handleComment
    else
      console.log   'Fatal Error: options#getContributors not provided'
      res.send 500, 'Fatal Error: options#getContributors not provided'

  else
    console.log   "Received \"#{payload.action}\", not an opened Pull Request"
    res.send 200, "Received \"#{payload.action}\", not an opened Pull Request"

exports.default = (req, res) ->
  res.send 'always at your service, clabot'