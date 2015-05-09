Timer = require 'timer'
Plugin = require 'plugin'
Event = require 'event'
Db = require 'db'

exports.getTitle = -> # prevents title input from showing up when adding the plugin

exports.onInstall = ->
	Db.shared.set 'story', ""	
	#Get a random user
	min = 1
	max = Plugin.userIds().length 
	id = Math.floor(Math.random() * (max - min) + min)
	log "Random user Id is " + id
	Db.shared.set 'userId', id
	
	#2 hours waiting time should be enough for each word
	exports.resetTimer()	

exports.onUpgrade = ->
	exports.nextPlayer()
	
exports.resetTimer = ->
	nextTime = (2 * 1000 * 60 * 60)
	Db.shared.set 'next', nextTime
	Timer.set nextTime, 'expire'

exports.nextPlayer = ->
	id = Db.shared.get 'userId' 
	id += 1		
	if id > Plugin.userIds().length
		#Back to first id (1)
		id = 1

	log "Next player should be: " + Plugin.userName(id)
	Db.shared.set 'userId', id
	exports.resetTimer()

exports.expire = ->
	#Waited too long, new player
	exports.nextPlayer()

exports.client_getTimeLeft = (cb) ->
	cb.reply Db.shared.set 'timeLeft'
	
exports.client_addWord = (uid, word) ->
	log "AddWord params: " + Plugin.userName(uid) + "-"+ uid + " " + word
	
	dbId = Db.shared.get 'userId'
	
	log "userId vs uid:" + uid + " vs " + dbId
	
	if dbId == uid
		#If the string is all spaces, return early		
		newWord = word.replace /^\s+|\s+$/g, ""
		#Make it lowerCase
		newWord = newWord.toLowerCase()
		#TODO: Make word capitalized if its after a period.
		if Db.shared.get 'story'.length == 0		
			newWord = newWord[0].toUpperCase() + newWord.substring(1)
			
		#Only get first word if multiple get in
		newWord = newWord.split(" ")[0]	

		exports.nextPlayer()
		
		Db.shared.modify 'story', (v) -> v + " " + newWord
		Event.create
			text: "The word '" + newWord + "' has been added!"
	
exports.client_deleteStory = ->
	Db.shared.set 'story', ""