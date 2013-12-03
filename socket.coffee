request = require 'request'
socketio = require 'socket.io'
express = require 'express'
Hangman = require './app/hangman'

DEBUG = false

class exports.Server

  constructor: (@port) ->

    @connect = require 'connect'
    flash = require 'connect-flash'


    MemoryStore = express.session.MemoryStore

    @app = express()

    # convert existing coffeescript, styl, and less resources to js and css for the browser
    @app.use require('connect-assets') src: __dirname + '/public'


    @app.set 'views', __dirname + '/app/views'
    @app.set 'view engine', 'jade'
    @app.use express.bodyParser()
    @app.use express.methodOverride()
    
    @app.use express.static(__dirname + '/public')
    @app.use express.cookieParser('guess')
    @app.use express.session { secret :'ci843tgbza11e', key: 'sessionID'}

    # error message handling
    @app.use(flash())

    #settings
    switch process.env.NODE_ENV
      when "development" 
        env = "development"
      when "production"
        env = "production" 
      else
         env = "development" # default development for now
    
    console.log env + " mode started"
    config = require("./app/config/config")[env]
    @DEBUG = config.debug
    
    #security stuff, aka login, authentication
    Security = require('./app/security').Security
    security = new Security
    security.init @app, (error, passport) =>
      @app.use @app.router


    #development
    @app.use(express.errorHandler({
      dumpExceptions: true, showStack: true
    }))

    # logging
    logger= (req, res, next) ->
      console.log "GOT REQUEST !", req.originalUrl, req.query
      next(); 

    @app.use logger

  start: (callback) ->

    console.log "DEBUG flag:", @DEBUG

    console.log 'Server starting'
    @http_server=@app.listen @port
    console.log 'Server listening on port ' + @port
   
    @app.get '/', (req, res) =>
      console.log "/ called "
      vars=
        foo: true
      res.render('index', vars)

    #TODO move partial templates into subfolder
    @app.get '/guess', (req, res) =>
      res.render('guess')


    @app.get '/login', (req, res) ->
      res.render('login', {user: req.user, message: req.flash('error')})

    # Socket IO
    @public=(socketio.listen @http_server)

    hangman = new Hangman 'Congratulations you guessed the sentence correctly'

    @public.sockets.on 'connection', (socket) ->
      hangman.check [], (match) -> 
        socket.emit('hangman', { phrase: match })

      socket.on 'guess', (data) -> 
        hangman.check data, (match) -> 
          socket.emit('hangman', { phrase: match })
        
  stop: (callback) ->
    console.log "Stop called"
    @private.server.close()
    callback()