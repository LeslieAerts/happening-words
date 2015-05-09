Timer = require 'timer'
Plugin = require 'plugin'
Event = require 'event'
Db = require 'db'

exports.getTitle = -> # prevents title input from showing up when adding the plugin

exports.onInstall = ->
	log "Plugin installed"

	Db.shared.set 'story', ""	
	min = 1
	max = Plugin.userIds().length 
	id = Math.floor(Math.random() * (max - min) + min)
	log "Random user Id is " + id
	Db.shared.set 'userId', id
	
	exports.resetTimer()	

exports.onUpgrade = ->
	#Not necessary to update on upgrade now
	exports.nextPlayer()
	
exports.resetTimer = ->
	Timer.cancel()
	nextTime = (2 * 1000 * 60 * 60)
	Timer.set nextTime, 'expire'	
	log "current Time is " + Date.now()
	#Plugin.time() is in seconds. nexttime is in millis so divide by 1000.
	#Time.deltaText is also in seconds. It calculates the difference between now and future (both need to be in seconds)
	nextTime = nextTime/1000 + Plugin.time() 
	Db.shared.set 'next', nextTime

exports.expire = ->
	log "Timer expired, next player is up"
	exports.nextPlayer()

exports.nextPlayer = ->
	userIds = Plugin.userIds()
	id = Db.shared.get 'userId'
	idx = userIds.indexOf(id)
	nextId = userIds[if idx? then (idx+1)%userIds.length else 0]
	
	log "Next player should be: " + Plugin.userName(nextId)
	Db.shared.set 'userId', nextId
	Event.create
		text: "It's your turn to add a new word!"
		include: nextId
		
	exports.resetTimer()

exports.client_getTimeLeft = (cb) ->
	cb.reply Db.shared.set 'timeLeft'
	
exports.client_addWord = (uid, word) ->
	log "AddWord params: " + Plugin.userName(uid) + "-"+ uid + " " + word
	
	dbId = Db.shared.get 'userId'
	
	log "userId vs uid:" + uid + " vs " + dbId
	
	if word.length == 0
		return 
		
	if dbId == uid
		#If the string is all spaces, return early		
		newWord = word.replace /^\s+|\s+$/g, ""

		#Make it lowerCase
		newWord = newWord.toLowerCase()
		story = Db.shared.get('story')
		if story.length == 0		
			newWord = newWord[0].toUpperCase() + newWord.substring(1)
			
		if (story[story.length-1] == ".") || (story[story.length-1] == "?") || (story[story.length-1] == "!")
			newWord = newWord[0].toUpperCase() + newWord.substring(1)	
			
		#Only get first word if multiple get in
		newWord = newWord.split(" ")[0]	

		exports.nextPlayer()
		
		Db.shared.modify 'story', (v) -> v + " " + newWord
		Event.create
			text: "The word '" + newWord + "' has been added!"
	
exports.client_deleteStory = ->
	Db.shared.set 'story', ""