var React = require('react');
var ReactDOM = require('react-dom');
var $ = require('jquery');
var _ = require('underscore');

window.$ = $;

var Game = React.createClass({
    componentWillMount: function() {
        this.cid = 0;
        this.ship = {x: 0, vx: 6};
        this.laser = {x: 0, y: 20, hp: 0};
        this.hero = {x: 0, y: 0, vx: 0, vy: 0};
        this.citizens = [];
        this.bombs = [];
        this.particles = [];
        this.nextBomb = 100;
        this.nextLaser = 200;
    },

    kill: function() {
        var $city = $('.city'),
            cityWidth = $city.width(),
            cityHeight = $city.height();
        this.citizens = _.filter(this.citizens, function(citizen) {
            return citizen.x >= -50 &&
                citizen.x <= cityWidth + 50 &&
                citizen.hp > 0;
        });
        this.bombs = _.filter(this.bombs, function(bomb) {
            return bomb.alive;
        });
        this.particles = _.filter(this.particles, function(particle) {
            return particle.t <= 100;
        });
    },

    spawn: function() {
        this.spawnCitizens();
        this.spawnBombs();
        this.fireLaser();
    },

    spawnCitizens: function() {
        var $city = $('.city'),
            cityWidth = $city.width();

        if (!$city.size()) {
            return;
        }

        if (Math.random() < 0.08) {
            var direction = Math.random() < 0.5 ? 1 : -1,
                vx = (8 + Math.random() * 2) * direction,
                x = direction === 1 ? -50 : cityWidth + 50;
            this.citizens.push({
                key: this.cid++,
                x: x,
                vx: vx,
                hp: 100,
                hit: false,
                panic: 0
            });
        }
    },

    spawnBombs: function() {
        if (this.nextBomb-- <= 0) {
            this.bombs.push({
                key: this.cid++,
                x: this.ship.x + 70,
                y: 90,
                vy: 8,
                alive: true
            });
            // Spawn bombs more frequently as time goes on.
            this.nextBomb = clamp(100, 10, 100 - Math.floor(this.props.tick / 2000) * 50);
        }
    },

    fireLaser: function() {
        if (this.nextLaser-- <= 0) {
            // Fire laser more frequently as time goes on.
            this.nextLaser = clamp(250, 100, 250 - Math.floor(this.props.tick / 2000) * 50);
            // Fire laser longer as time goes on.
            this.laser.hp = clamp(100, 35, 35 + Math.floor(this.props.tick / 2000) * 50);
        }
    },

    update: function() {
        var self = this,
            $city = $('.city'),
            cityWidth = $city.width(),
            cityPos = $city.position();

        if (!$city.size()) {
            return;
        }

        this.ship.x += this.ship.vx;
        if (this.ship.x <= 0 || this.ship.x + 207 >= cityWidth) {
            this.ship.vx *= -1;
        }
        this.laser.x = this.ship.x + 92;
        this.laser.hp--;

        _.each(this.citizens, function(citizen) {
            if (citizen.hit) {
                citizen.hp--;
            } else {
                citizen.x += citizen.vx;
            }
            if (citizen.panic > 0) {
                citizen.panic--;
            }
        });

        _.each(this.bombs, function(bomb) {
            bomb.y += bomb.vy;
        });

        _.each(this.particles, function(p) {
            p.x = tween(p.t, p.x1, p.x2 - p.x1, 100);
            p.y = tween(p.t, p.y1, p.y2 - p.y1, 100);
            // Fade out from 100% to 30%
            p.opacity = tween(p.t, 1, 0.3 - 1, 100);
            p.t += 3;
        });

        // Collide
        for (var i = 0; i < this.bombs.length; i++) {
            var bomb = this.bombs[i];
            for (var j = 0; j < this.citizens.length; j++) {
                if (this.citizens[j].hit) {
                    continue;
                }
                var citizen = this.citizens[j],
                    buffer = 5,
                    r1 = { left: bomb.x, right: bomb.x + 63,
                           top: bomb.y, bottom: bomb.y + 63 },
                    r2 = { left: citizen.x + buffer, right: citizen.x + 26 - buffer,
                           top: cityPos.top + buffer, bottom: cityPos.top + 54 };
                if (intersectRect(r1, r2)) {
                    citizen.hit = true;
                    bomb.alive = false;
                }
            }
        }

        for (var i = 0; i < this.particles.length; i++) {
            var particle = this.particles[i];
            for (var j = 0; j < this.citizens.length; j++) {
                var citizen = this.citizens[j];
                if (citizen.hit || citizen.panic > 0) {
                    continue;
                }
                var r1 = { left: particle.x, right: particle.x + 25,
                           top: particle.y, bottom: particle.y + 25 },
                    r2 = { left: citizen.x, right: citizen.x + 26,
                           top: cityPos.top, bottom: cityPos.top + 54 };
                if (intersectRect(r1, r2)) {
                    citizen.vx = -citizen.vx;
                    citizen.panic = 100;
                }
            }
        }

        if (this.laser.hp > 0) {
            for (var j = 0; j < this.citizens.length; j++) {
                if (this.citizens[j].hit) {
                    continue;
                }
                var citizen = this.citizens[j],
                    r1 = { left: this.laser.x, right: this.laser.x + 20,
                           top: 0, bottom: 1 },
                    r2 = { left: citizen.x, right: citizen.x + 26,
                           top: 0, bottom: 1 };
                if (intersectRect(r1, r2)) {
                    citizen.hit = true;
                }
            }
        }

        _.each(this.bombs, function(bomb) {
            if (bomb.y + 10 >= cityPos.top) {
                bomb.alive = false;
            }
            if (!bomb.alive) {
                self.explosion(bomb.x, cityPos.top);
            }
        });
    },

    explosion: function(x, y) {
        var x1 = x;
        var y1 = y + 20;
        var slices = 8,
            slice = Math.PI  / slices,
            radius = 200;
        for (var i = 0; i <= slices; i++) {
            var angle = Math.PI * 2 - slice * i,
                x2 = x1 + Math.cos(angle) * radius,
                y2 = y1 + Math.sin(angle) * radius;
            this.particles.push({
                key: this.cid++,
                t: 0,
                x1: x1,
                y1: y1,
                x2: x2,
                y2: y2,
                opacity: 1
            });
        }
    },

    render: function() {
        this.kill();
        this.spawn();
        this.update();

        var citizens = _.map(this.citizens, function(citizen) {
            return <Citizen {...citizen} />;
        });

        var bombs = _.map(this.bombs, function(bomb) {
            return <Bomb {...bomb} />;
        });

        var particles = _.map(this.particles, function(particle) {
            return <Particle {...particle} />;
        });

        var laser = null;
        if (this.laser.hp > 0) {
            laser = <Laser {...this.laser} />;
        }

        return (
            <div>
                <div className="city">
                    {citizens}
                </div>
                <div className="particles">
                    {particles}
                </div>
                <div className="upper-city">
                    {laser}
                    {bombs}
                </div>
                <div className="sky">
                    <Ship {...this.ship} />
                </div>
                <div className="tick">FPS {this.props.fps}</div>
            </div>
        );
    }
});

var Sprite = React.createClass({
    render: function() {
        var style = {
                top: (this.props.y || 0) + 'px',
                left: (this.props.x || 0) + 'px'
            },
            className = this.props.name + (this.props.hit ? ' hit' : '');

        if (typeof this.props.opacity !== 'undefined') {
            style.opacity = this.props.opacity || 1;
        }

        return <div className={className} style={style}></div>;
    }
});

var Citizen = React.createClass({
    render: function() {
        return <Sprite name="citizen"
                    x={this.props.x}
                    y={this.props.y}
                    hit={this.props.hit} />
    }
});

var Ship = React.createClass({
    render: function() {
        return <Sprite name="ship" x={this.props.x} y={this.props.y} />;
    }
});

var Bomb = React.createClass({
    render: function() {
        return <Sprite name="bomb" x={this.props.x} y={this.props.y} />;
    }
});

var Particle = React.createClass({
    render: function() {
        return <Sprite name="particle" x={this.props.x} y={this.props.y} opacity={this.props.opacity} />;
    }
});

var Laser = React.createClass({
    render: function() {
        return <Sprite name="laser" x={this.props.x} y={this.props.y} />;
    }
});

// Utils

function intersectRect(r1, r2) {
  return !(r2.left > r1.right ||
           r2.right < r1.left ||
           r2.top > r1.bottom ||
           r2.bottom < r1.top);
}

// t=current time
// b=start value
// c=change in value
// d=duration
function tween(t, b, c, d) {
    // easeOutQuad
	t /= d;
	return -c * t*(t-2) + b;
}

function clamp(hi, lo, value) {
    return Math.min(hi, Math.max(lo, value));
}

// Game loop

var tick = 0;
var fps = 0;
var frames = 0;
var duration = 0;
var d1 = new Date().getTime();
var paused = false;

function update() {
    var d2 = new Date().getTime();
    duration += (d2 - d1);
    d1 += (d2 - d1);
    frames++;
    fps = Math.floor(frames / (duration / 1000));

    if (!paused) {
        ReactDOM.render(
          <Game tick={tick++} fps={fps} />,
          document.getElementById('container')
        );
    }

    var d3 = new Date().getTime();
    var target_fps = 60;
    var delay = 1000 / target_fps - (d3 - d2);
    setTimeout(update, delay);
}
update();

setTimeout(function() {
    $('.preload').hide();
}, 5);

$('body').on('keyup', function(e) {
    if (e.which === 32) {
        paused = !paused;
        if (paused) {
            $('#paused').show();
        } else {
            $('#paused').hide();
        }
    }
});