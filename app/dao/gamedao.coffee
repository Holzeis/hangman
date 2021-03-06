restful = require 'node-restful'
mongoose = restful.mongoose

Game = require '../models/game'

class GameDao

  @init: (@io) ->
    GameEngine = require('../hangman/gameengine').GameEngine

    gamedao = @
    @retrieveGames (err, games) ->
      throw err if err
      gamedao.commands = new Array()
      for game in games
        engine = new GameEngine io, game
        gamedao.commands[game.name] = new Array()
        gamedao.commands[game.name]['instance'] = engine
        gamedao.commands[game.name]['functions'] = ['join', 'leave', 'guess', 'report']
        engine.start()
      GameDao.logger().info "initialised games"

  @logger: () ->
    @io.log

  @retrieveGames: (callback) ->
    Game.find {}, (err, games) ->
      callback err, games

module.exports = GameDao