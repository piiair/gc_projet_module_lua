local game = {}

local SettingsMod = require("settings")
local GoldMod = require("gold")
local DepositMod = require("deposit")
local ExplodeMod = require("explodeModule")
local MiningMod = require("miningModule")
local Tank = require("tank")
local UpMod = require("upgrade")
local EnemyMod = require("enemyModule")
local ShotMod = require("shotModule")
local GuiGame = require("guiGame")

local GameMode
local sndSources

local map = love.graphics.newImage("images/map.png")

local function resetModules()
  GuiGame.resetGui()
  Tank.reset()
  EnemyMod.reset()
  MiningMod.reset()
  ShotMod.listShots = nil
  ExplodeMod.listExplodes = nil
  GoldMod.listCoin = nil
  UpMod.listBul = nil
end

local function startNewGame()
  resetModules()
  GameMode = "game"

  Tank.load()
  ShotMod.load()
  EnemyMod.load()
  MiningMod.load(Tank)
  ExplodeMod.load()
  GoldMod.load()
  UpMod.load()
  GuiGame.loadGameGroup()
  love.mouse.setGrabbed(true)
end

local function startMenu()
  resetModules()
  GameMode = "menu"
  GuiGame.loadMenuGroup()
  love.mouse.setGrabbed(false)
end

local function manageSounds(Action)
  if Action == "pause" then
    sndSources = love.audio.pause()
  elseif Action == "resume" then
    love.audio.play(sndSources)
  end
end

function game.init()
  GuiGame.loadMenuGroup()
  GameMode = "menu"
end

function game.update(dt)
  if GameMode == "menu" then
    --elseif GameMode == "setGame"
    GuiGame.updateMenuGroup(dt)

    if GuiGame.menuGroup.elements[1].isPressed then
      startNewGame()
    end
  elseif GameMode == "game" then
    --Game
    ExplodeMod.update(dt)
    Tank.update(dt)
    EnemyMod.update(dt, Tank)
    ShotMod.update(dt)
    MiningMod.update()
    GoldMod.update(dt)
    GuiGame.updateGameGroup(dt)

    --changement si victoire ou defaite (priorité à la défaite en cas d'égalité)
    if Tank.gameOver then
      GameMode = "gameOver"
      GuiGame.loadGameOverGroup()
      love.mouse.setGrabbed(false)
    elseif EnemyMod.playerVictory then
      GameMode = "victory"
      GuiGame.loadVictoryGroup()
      love.mouse.setGrabbed(false)
    end
  elseif GameMode == "break" then
    GuiGame.updateBreakGroup(dt)
    if GuiGame.breakGroup.elements[1].isPressed then
      startNewGame()
    elseif GuiGame.breakGroup.elements[2].isPressed then
      startMenu()
    end
    
  elseif GameMode == "victory" then
    GuiGame.updateVictoryGroup(dt)

    if GuiGame.victoryGroup.elements[2].isPressed then
      
      startNewGame()
    elseif GuiGame.victoryGroup.elements[3].isPressed then
      startMenu()
    end
  elseif GameMode == "gameOver" then
    GuiGame.updateGameOverGroup(dt)

    if GuiGame.gameOverGroup.elements[1].isPressed then
      startNewGame()
    elseif GuiGame.gameOverGroup.elements[2].isPressed then
      startMenu()
    end
  end
end

function game.draw()
  if GameMode == "menu" then
    GuiGame.menuGroup:draw()
  elseif GameMode == "game" then
    love.graphics.draw(map, 0, 0)
    ShotMod.draw()
    MiningMod.draw()
    DepositMod.draw()
    GoldMod.draw()
    Tank.draw()
    EnemyMod.draw()
    ExplodeMod.draw()
    GuiGame.gameGroup:draw()
    GuiGame.drawBarsGameGroup()
  elseif GameMode == "break" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.draw(map, 0, 0)
    ShotMod.draw()
    MiningMod.draw()
    DepositMod.draw()
    GoldMod.draw()
    Tank.draw()
    EnemyMod.draw()
    ExplodeMod.draw()
    GuiGame.gameGroup:draw()
    GuiGame.drawBarsGameGroup()
    love.graphics.setColor(1, 1, 1)
    GuiGame.breakGroup.draw()
  elseif GameMode == "victory" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.draw(map, 0, 0)
    ShotMod.draw()
    MiningMod.draw()
    DepositMod.draw()
    GoldMod.draw()
    Tank.draw()
    EnemyMod.draw()
    GuiGame.gameGroup:draw()
    love.graphics.setColor(1, 1, 1)
    GuiGame.victoryGroup.draw()
  elseif GameMode == "gameOver" then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.draw(map, 0, 0)
    ShotMod.draw()
    MiningMod.draw()
    DepositMod.draw()
    GoldMod.draw()
    EnemyMod.draw()
    GuiGame.gameGroup:draw()
    love.graphics.setColor(1, 1, 1)
    GuiGame.gameOverGroup.draw()
  end
end

function love.keypressed(key)
  if key == "escape" then
    if GameMode == "menu" then
      love.event.quit()
    elseif GameMode == "game" then
      GameMode = "break"
      GuiGame.loadBreakGroup()
      love.mouse.setGrabbed(false)
      manageSounds("pause")
    elseif GameMode == "break" then
      GameMode = "game"
      manageSounds("resume")
      love.mouse.setGrabbed(true)
    end
  end

  if GameMode == "game" then 
    Tank.keypressed(key)
  end
end

return game
