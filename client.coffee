Page = require 'page'
Ui = require 'ui'
Obs = require 'obs'

exports.render = ->
	screen = Page.state.get(0)
	if screen == "story"
	Page.setTitle("Story")
	renderStory()`
	#Ui.button "Add Word", !->

renderStory = ->
	#TODO
	
