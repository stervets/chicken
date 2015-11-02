// Generated by CoffeeScript 1.9.1
(function() {
  this.LOCAL_METHOD = 'localMethod';

  this.LOCAL_PROPERTY = 'localProperty';

  this.LOCAL_SCOPE = 'localScope';

  this.FACTORY = 'ApplicationFactory';

  this.DATABASE_NAME = "https://clucking.firebaseio.com/";

  this.APP_STATE = {
    LOADING: 0,
    ERROR: 1,
    ASK_NAME: 2,
    READY: 3
  };

  this.CHICKEN_STATE = {
    IDLE: 'idle',
    CLUCK: 'cluck',
    MOVE: 'move',
    POOP: 'poop'
  };

  this.BOUNDS = {
    x1: 10,
    x2: 800,
    y1: 200,
    y2: 450
  };

  this.SPRITE = {
    w: 148,
    h: 110,
    line: 6,
    speed: Math.round(1000 / 25),
    idle: 67,
    move: 24,
    cluck: 45,
    poop: 20
  };

}).call(this);

//# sourceMappingURL=config.js.map
