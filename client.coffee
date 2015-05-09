Db = require 'db'
Dom = require 'dom'
Ui = require 'ui'
Form = require 'form'
Modal = require 'modal'
Server = require 'server'
Page = require 'page'
Plugin = require 'plugin'
Obs = require 'obs'
Time = require 'time'
{tr} = require 'i18n'
Social = require 'social'

curUserId = Plugin.userId()
	
# This is the main entry point for a plugin:
exports.render = !->
	renderMain()

renderMain = ->
	Page.setTitle("Word Story")

	#Story header
	Dom.section ->
		Dom.div ->
			Dom.style 
				textAlign: 'center'	
			Dom.h1 tr("The story of " + Plugin.groupName())
			Dom.text  Db.shared.get('story')	
	
	#Whose turn is it
	Dom.div !-> 
		Dom.style
			textAlign: 'right'
		Ui.avatar Plugin.userAvatar(Db.shared.get('userId'))
		Dom.text tr("'s turn")
	
	Obs.observe !->
		#Time stuff here
		Dom.div !-> 
			Dom.style
				textAlign: 'right'
			Dom.text "Turn ends "
			Time.deltaText(Db.shared.get('next')) 
			
	Dom.div ->
		Dom.style 
			textAlign: 'right'	
		Ui.item !->
			word = Form.input
				text: 'Word'
				title: "Add a word"	
			Ui.button tr("Add"), !->
				Server.call 'addWord', curUserId, word.value()
				word.value("")
#	if Plugin.userIsAdmin()
#		Ui.button "Delete Story", !->
#			Server.call 'deleteStory'

	require('social').renderComments()