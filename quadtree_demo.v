module main

import quadtree
import gg
import gx
import os
import time
import math
import rand

const (
        win_width    = 1340
        win_height   = 640
        timer_period = 40 * time.millisecond // defaulted at 25 fps
        font_small   = gx.TextCfg{
                color: gx.black
                size: 20
        }
        font_large = gx.TextCfg{
                color: gx.black
                size: 40
        }
)

struct App {
mut:
        gg         &gg.Context
        qt         quadtree.Quadtree
        players    []quadtree.AABB
        particles  []Particle
        retrieveds []quadtree.AABB
        nodes      []quadtree.Quadtree
        width      f64 = 1340
        height     f64 = 640
}

struct Particle {
mut:
        pmt   quadtree.AABB
        speed f64
        angle f64
}

fn (mut p Particle) update() {
        p.pmt.x += p.speed * math.cos(p.angle * math.pi / 180)
        p.pmt.y += p.speed * math.sin(p.angle * math.pi / 180)

        if p.pmt.x < 0 {
                p.pmt.x = 0
                p.speed = -p.speed
                p.angle = -p.angle
        }
        if p.pmt.x > 1340 {
                p.pmt.x = 1340
                p.speed = -p.speed
                p.angle = -p.angle
        }
        if p.pmt.y < 0 {
                p.pmt.y = 0
                p.speed = -p.speed
                p.angle = 180 - p.angle
        }
        if p.pmt.y > 640 {
                p.pmt.y = 640
                p.speed = -p.speed
                p.angle = 180 - p.angle
        }
}

fn (mut app App) start() {
        app.players << quadtree.AABB{rand.f64n(1200.0), rand.f64n(500.0), 20, 20}
        app.insert_particles()
        for mut particle in app.particles {
                particle.speed = 10 * rand.f64()
                particle.angle = 200 * rand.f64()
        }
        app.nodes << app.qt.get_nodes()
}

fn (mut app App) update() {
        app.qt.clear()
        app.nodes = []
        for mut particle in app.particles {
                particle.update()
                app.qt.insert(particle.pmt)
        }
        app.find_particles()
        app.nodes << app.qt.get_nodes()
}

fn (mut app App) insert_particles() {
        mut grid := 10.0
        mut gridh := app.qt.perimeter.width / grid
        mut gridv := app.qt.perimeter.height / grid
        num_particles := 100
        for _ in 0 .. num_particles {
                mut x := rand_minmax(0, gridh) * grid
                mut y := rand_minmax(0, gridv) * grid
                mut random_particle := quadtree.AABB{
                        x: x
                        y: y
                        width: rand_minmax(1, 4) * grid
                        height: rand_minmax(1, 4) * grid
                }
                app.particles << Particle{random_particle, 0.0, 0.0}
        }
        // app.cleanup()
}

fn (mut app App) find_particles() {
        app.retrieveds = []
        app.retrieveds << app.qt.retrieve(app.players[0])
}

// [manualfree]
// fn (mut app App) cleanup() {
//         unsafe { app.qt.particles.free() }
// }

[console]
fn main() {
        mut app := &App{
                gg: 0
        }
        app.gg = gg.new_context(
                bg_color: gx.white
                width: win_width
                height: win_height
                use_ortho: true
                create_window: true
                window_title: 'quadtree_demo'
                frame_fn: frame
                event_fn: on_event
                user_data: app
                font_path: os.resource_abs_path('./fonts/RobotoMono-Regular.ttf')
        )
        app.qt = c_qt(0, 0, 1340, 640, 8, 4, 0)
        app.start()
        go app.run()
        app.gg.run()
}

fn (mut app App) on_mouse_move(mouse_x f32, mouse_y f32) {
        for mut player in app.players {
                player.x = (mouse_x / gg.window_size_real_pixels().width) * 1340
                player.y = (mouse_y / gg.window_size_real_pixels().height) * 640
        }
}

fn on_event(mut e gg.Event, mut app App) {
        match e.typ {
                .mouse_move { app.on_mouse_move(e.mouse_x, e.mouse_y) }
                else {}
        }
}

fn (mut app App) run() {
        for {
                app.update()
                time.sleep(timer_period)
        }
}

fn frame(app &App) {
        app.gg.begin()
        app.draw()
        app.gg.end()
}

fn (app &App) display() {
        for player in app.players {
                app.gg.draw_rect(f32(player.x), f32(player.y), f32(player.width), f32(player.height),
                        gx.black)
        }
        for particle in app.particles {
                app.gg.draw_empty_rect(f32(particle.pmt.x), f32(particle.pmt.y), f32(particle.pmt.width),
                        f32(particle.pmt.height), gx.blue)
        }
        for node in app.nodes {
                app.gg.draw_empty_rect(f32(node.perimeter.x), f32(node.perimeter.y), f32(node.perimeter.width),
                        f32(node.perimeter.height), gx.red)
        }
        for retrieved in app.retrieveds {
                app.gg.draw_rect(f32(retrieved.x + 1), f32(retrieved.y + 1), f32(retrieved.width - 2),
                        f32(retrieved.height - 2), gx.green)
        }
        app.gg.draw_text(1200, 25, 'Nodes: $app.qt.get_nodes().len', font_small)
        app.gg.draw_text(1200, 50, 'Particles: $app.particles.len', font_small)
}

fn (app &App) draw() {
        app.display()
}

// Helpers
fn c_qt(x f64, y f64, width f64, height f64, capacity int, depth int, level int) quadtree.Quadtree {
        return quadtree.Quadtree{
                perimeter: quadtree.AABB{
                        x: x
                        y: y
                        width: width
                        height: height
                }
                capacity: capacity
                depth: depth
                level: level
                particles: []quadtree.AABB{}
                nodes: []quadtree.Quadtree{len: 0, cap: 4}
        }
}

fn rand_minmax(min f64, max f64) f64 {
        mut val := min + (rand.f64() * (max - min))
        return val
}