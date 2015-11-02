@LOCAL_METHOD = 'localMethod'
@LOCAL_PROPERTY = 'localProperty'
@LOCAL_SCOPE = 'localScope'
@FACTORY = 'ApplicationFactory'

@DATABASE_NAME = "https://clucking.firebaseio.com/"

@APP_STATE =
    LOADING: 0
    ERROR: 1
    ASK_NAME: 2
    READY: 3

@CHICKEN_STATE =
    IDLE: 'idle'
    CLUCK: 'cluck'
    MOVE: 'move'
    POOP: 'poop'

@BOUNDS =
    x1: 10
    x2: 800
    y1: 200
    y2: 450

@SPRITE =
    w: 148
    h: 110
    line: 6
    speed: Math.round(1000/25)
    idle: 67
    move: 24
    cluck: 45
    poop: 20
