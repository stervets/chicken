###
    Angular application
###
app = new Triangle 'CluckingClubApplication', ['firebase', 'ngAnimate']

###
    Sound player class
###
class Sound
    file: null
    play: =>
        @file.pause()
        @file.currentTime = 0
        @file.play()

    constructor: (name)->
        @file = new Audio()
        @file.src = "snd/#{name}.mp3"

###
    Application main factory
###
app.factory FACTORY,
    inject: '$firebaseObject, $firebaseArray, $rootScope'

    db: new Firebase DATABASE_NAME
    app:
        state: APP_STATE.LOADING # application state
        userFirebaseObject: null # user $firebaseObject
        user: null # user binded to $scope object
        users: null #all users array
        poops: null # poops array
        error: false # database login error
        message: '' # message to send

    cluckSounds: [] # some variative cluck sounds
    fartSound: null # fart sound
    cleanSound: null # clean up sound

    # return random number between min and max
    rand: (min, max)->
        [max, min] = [min, 0] unless max?
        Math.floor(Math.random() * (max - min + 1)) + min

    playCluckSound: ->
        @cluckSounds[@rand(0, 2)].play()

    playFartSound: ->
        @fartSound.play()

    playCleanUpSound: ->
        @cleanSound.play()

    # Set "ask for name" state
    onUserFirebaseObjectLoaded: ->
        @app.state = APP_STATE.ASK_NAME

    # Database login handler
    onAuthAnonymously: (error, authData)->
        if error
            angular.extend @app,
                state: APP_STATE.ERROR
                error: "Unable to connect to firebase: #{error}"
            @$rootScope.$apply()
        else
            userReference = @db.child("chicken/#{authData.uid}")
            @app.userFirebaseObject = @$firebaseObject userReference
            @app.userFirebaseObject.$loaded @onUserFirebaseObjectLoaded
            userReference.onDisconnect().remove()

            @app.users = @$firebaseArray @db.child('chicken').orderByChild('-score')
            @app.poops = @$firebaseArray @db.child('poops').limitToLast(100)

    init: ->
        @cluckSounds.push(new Sound("cluck#{i}")) for i in [0..2]
        @fartSound = new Sound 'fart'
        @cleanSound = new Sound 'clean'
        @db.authAnonymously @onAuthAnonymously

###
    Application main controller
###
app.controller 'MainController',
    inject: [FACTORY]
    local:
        scope:
            APP_STATE: APP_STATE
            app: FACTORY
            rand: FACTORY
            onEnterName: LOCAL_PROPERTY
            addScore: LOCAL_METHOD

        ###
            Add score to player
        ###
        addScore: (poop)->
            return unless @app.user?
            @app.user.score++
            @app.poops.$remove poop

        ###
            Name form submit handler
        ###
        onEnterName: ->
            @app.state = APP_STATE.READY if @app.user.name.trim()
        ###
            On name form submit success
        ###
        onChangeAppState: ->
            return unless @app.state is APP_STATE.ASK_NAME
            @app.userFirebaseObject.$value =
                name: 'Clucker #' + @rand(1, 999)
                x: @rand(50, 800)
                y: @rand(200, 500)
                state: CHICKEN_STATE.IDLE
                score: 0
            @app.userFirebaseObject.$save()
            @app.userFirebaseObject.$bindTo(@$scope, 'user').then @onUserReady

        ###
            Fired on bind userFirebaseObject to @$scope.user
        ###
        onUserReady: ->
            @app.user = @$scope.user

        watch:
            'app.state': 'onChangeAppState'


###
    Chicken directive
###
app.directive "chicken",
    restrict: Triangle.DIRECTIVE_TYPE.ELEMENT
    templateUrl: 'jsChicken'
    inject: [FACTORY]
    scope:
        chicken: '=model'

    local:
        scope:
            playCluckSound: FACTORY
            playFartSound: FACTORY
            playCleanUpSound: FACTORY
            rand: FACTORY
            app: FACTORY
            chicken: LOCAL_SCOPE
            state: LOCAL_PROPERTY
            onChickenClick: LOCAL_METHOD

        state:
            reversed: 'normal'
            name: CHICKEN_STATE.IDLE
            frame: 0

        sprite: null #chicken sprite
        timeout: null

        clearTimeout: ->
            return unless @timeout?
            clearTimeout @timeout
            @timeout = null

        setIdleState: ->
            return unless @app.user
            @app.user.state = CHICKEN_STATE.IDLE
            @clearTimeout()
            @$scope.$apply()

        # Poop if chicken is user, append chicken name to message form otherwise
        onChickenClick: ()->
            return unless @app.user
            if @app.user.$id is @chicken.$id
                @setState CHICKEN_STATE.POOP, 700
                @app.poops.$add
                    x: @chicken.x + (if @state.reversed is 'normal' then -70 else -40)
                    y: @chicken.y + 40
            else
                @app.message = "#{@chicken.name}, #{@app.message}"

        # Show cluck animation if got new message
        onChickenMessageChange: (message)->
            return unless message
            @setState CHICKEN_STATE.CLUCK, 1000

        # set animation state
        setState: (stateName, time)->
            return unless @app.user and @app.user.$id is @chicken.$id
            @app.user.state = stateName
            @clearTimeout()
            @timeout = setTimeout @setIdleState, time

        onChickenStateChange: (state)->
            @state.name = state || CHICKEN_STATE.IDLE
            return unless state?
            @playCluckSound() if state is CHICKEN_STATE.CLUCK
            @playFartSound() if state is CHICKEN_STATE.POOP
            @state.frame = 0

        # Chicken X coordinate handler
        onChickenXChange: (newVal, oldVal)->
            @setState CHICKEN_STATE.MOVE, 1000
            @state.reversed = if newVal < oldVal then 'reversed' else 'normal'

        onChickenScore: ->
            @playCleanUpSound()

        # next animation frame
        nextFrame: ->
            @state.frame = 0 if @state.frame > SPRITE[@state.name]
            @sprite.css
                backgroundPositionX: "-#{((@state.frame % SPRITE.line) * SPRITE.w + 60)}px"
                backgroundPositionY: "-#{((Math.round((@state.frame) / SPRITE.line) - 1) * SPRITE.h)}px"
            @state.frame++
            setTimeout @nextFrame, SPRITE.speed

        watch:
            'chicken.message': 'onChickenMessageChange'
            'chicken.state': 'onChickenStateChange'
            'chicken.x': 'onChickenXChange'
            'chicken.score': 'onChickenScore'

    link: ->
        @sprite = @$element.find '.sprite'
        @state.frame = @rand 0, 50
        @nextFrame()


###
    Controls directive
###
app.directive "controls",
    restrict: Triangle.DIRECTIVE_TYPE.ATTRIBUTE
    inject: [FACTORY]

    local:
        scope:
            app: FACTORY
            send: LOCAL_PROPERTY
            sendMessage: LOCAL_METHOD

        state:
            reversed: 'normal'
            name: CHICKEN_STATE.IDLE
            frame: 0

        timeout: null

        clearTimeout: ->
            return unless @timeout?
            clearTimeout @timeout
            @timeout = null

        clearMessage: ->
            angular.extend @$scope.user,
                time: 0
            @timeout = null
            @$scope.$apply()

        sendMessage: ->
            if (@app.user? and (message = @app.message.trim()))
                @clearTimeout()
                angular.extend @app.user,
                    message: message
                    time: Date.now()
                @timeout = setTimeout @clearMessage, 5000
            @app.message = ''

        onMovableClick: (e)->
            return unless @app.user?
            angular.extend @app.user,
                x: e.layerX + 40
                y: e.y - 90
            @$scope.$apply()

    events:
        'click .movable': 'onMovableClick'
