module quadtree

import time

fn test_create() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        test_clone := qt.create(0, 0, 1340, 640, 8, 4, 0)
        assert test == test_clone
        println('create passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_get_nodes() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        test.split()
        t := test.get_nodes()
        assert t.len == 4
        println('get_nodes passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_insert() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        mut pt := AABB{
                x: 100
                y: 50
                width: 60
                height: 100
        }
        assert test.particles == []
        test.insert(pt)
        assert test.particles[0] == pt
        println('insert passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_retrieve() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        mut pt := AABB{
                x: 100
                y: 50
                width: 60
                height: 100
        }
        test.insert(pt)
        t := test.retrieve(pt)
        assert t[0] == pt
        println('retrieve passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_clear() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        mut test_clone := qt.create(0, 0, 1340, 640, 8, 4, 0)
        mut pt := AABB{
                x: 100
                y: 50
                width: 60
                height: 100
        }
        test.split()
        test.insert(pt)
        assert test != test_clone
        test.clear()
        assert test == test_clone
        println('clear passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_split() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        test.split()
        t := test.get_nodes()
        assert t.len == 4
        println('split passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}

fn test_get_index() {
        mut sw := time.new_stopwatch()
        mut qt := Quadtree{}
        mut test := qt.create(0, 0, 1340, 640, 8, 4, 0)
        mut pt := AABB{
                x: 100
                y: 50
                width: 60
                height: 100
        }
        test.particles << pt
        t := test.get_index(pt)
        assert t == [1]
        println('get_index passed')
        sw.stop()
        println('microseconds: $sw.elapsed().microseconds()')
}