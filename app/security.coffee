async = require 'async'
User = require './models/user'
passport = require 'passport'
bcrypt = require 'bcrypt'

class exports.Security

  init: (app, callback) ->

    self=@
    app.use passport.initialize()
    app.use passport.session()

    LocalStrategy = require('passport-local').Strategy
    
    passport.use new LocalStrategy 
      usernameField: 'email',
      passwordField: 'password'
    , (email, password, done) ->

      process.nextTick ->
        condition = 
          email: email
        User.findOne condition, (err, user) ->
          return done(err)  if err
          unless user
            return done(null, false,
              message: "Incorrect username or password."
            )
          unless user.password==password #TODO encrypt password
            return done(null, false, message: "Incorrect password.")
          done null, user


    passport.serializeUser (user, done) ->
      done(null, user._id)

    passport.deserializeUser (id, done) ->
      User.findById id, done  

    app.post '/login', passport.authenticate('local', { successRedirect: '/',  failureRedirect: '/', failureFlash: true })

    app.post "/register", (req, res) ->  
      # attach POST to user schema
      user = new User(
        email: req.body.email
        password: req.body.password
      )      
      # save in Mongo
      user.save (err) ->
        if err
          console.log err
        else
          console.log "user: " + user.email + " saved."
          req.login user, (err) ->
            console.log err  if err
            res.redirect "/"

    app.get "/activate", (req, res) ->
      token = req.query["token"]
      User.findOne token: token, (err, data) ->
        return next(err)  if err
        unless data
          res.send "Token not found. Where are u come from?"
        else
          _email = data.email
          if data.activated is true
            res.send "Your account has already been activated. Just head to the login page."
          else
            data.activated = true
            data.save()
            res.render "index",
              message: "Please sign in " + data.email

