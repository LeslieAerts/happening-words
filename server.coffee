Timer = require 'timer'
Plugin = require 'plugin'
Db = require 'db'

exports.onInstall = ->
	# set the counter to 0 on plugin installation
	Db.shared.set 'story', ""
	
	#Get a random user
	min = 1
	max = Plugin.userIds().length
	id = Math.random() * (max - min) + min
	log "Random user Id is " + id
	Db.shared.set 'userId', Plugin.userIds()[0]
	
exports.client_getTimeLeft = (cb) ->
	cb.reply new Date() + 1000
	
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
			newWord[0].toUpperCase()		

		#Only get first word if multiple get in
		newWord = newWord.split(" ")[0]	
		id = dbId 
		id += 1		
		if id > Plugin.userIds().length
			#Back to first id (1)
			id = 1
		
		log "Next player should be: " + Plugin.userName(id)
		Db.shared.set 'userId', id
		Db.shared.modify 'story', (v) -> v + " " + newWord
	
exports.client_deleteStory = ->
	Db.shared.set 'story', ""