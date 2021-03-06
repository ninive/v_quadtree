module quadtree

pub struct AABB {
pub mut:
        x      f64
        y      f64
        width  f64
        height f64
}

pub struct Quadtree {
pub mut:
        perimeter AABB
        capacity  int
        depth     int
        level     int
        nodes     []Quadtree
        particles []AABB
}

fn (mut p AABB) is_point() bool {
        if p.width == 0 && p.height == 0 {
                return true
        }
        return false
}

// Simple collision helper
fn (mut p AABB) intersects(a AABB) bool {
        amx_x := a.x + a.width
        amx_y := a.y + a.height
        bmx_x := p.x + p.width
        bmx_y := p.y + p.height

        if amx_x < p.x {
                return false
        }

        if a.x > bmx_x {
                return false
        }

        if amx_y < p.y {
                return false
        }

        if a.y > bmx_y {
                return false
        }

        return true
}

pub fn (mut q Quadtree) clear() {
        q.particles = []
        for j in 0 .. q.nodes.len {
                if q.nodes.len > 0 {
                        q.nodes[j].clear()
                }
        }
        q.nodes = []
}

pub fn (q Quadtree) get_nodes() []Quadtree {
        mut nodes := []Quadtree{}
        if q.nodes.len > 0 {
                for j in 0 .. q.nodes.len {
                        nodes << q.nodes[j]
                        nodes << q.nodes[j].get_nodes()
                }
        }
        return nodes
}

pub fn (mut q Quadtree) split() {
        if q.nodes.len == 4 {
                return
        }

        next_level := q.level + 1
        child_width := q.perimeter.width / 2
        child_height := q.perimeter.height / 2
        x := q.perimeter.x
        y := q.perimeter.y

        //(0)
        q.nodes << Quadtree{
                perimeter: AABB{
                        x: x + child_width
                        y: y
                        width: child_width
                        height: child_height
                }
                capacity: q.capacity
                depth: q.depth
                level: next_level
                particles: []AABB{}
                nodes: []Quadtree{len: 0, cap: 4}
        }

        //(1)
        q.nodes << Quadtree{
                perimeter: AABB{
                        x: x
                        y: y
                        width: child_width
                        height: child_height
                }
                capacity: q.capacity
                depth: q.depth
                level: next_level
                particles: []AABB{}
                nodes: []Quadtree{len: 0, cap: 4}
        }

        //(2)
        q.nodes << Quadtree{
                perimeter: AABB{
                        x: x
                        y: y + child_height
                        width: child_width
                        height: child_height
                }
                capacity: q.capacity
                depth: q.depth
                level: next_level
                particles: []AABB{}
                nodes: []Quadtree{len: 0, cap: 4}
        }

        //(3)
        q.nodes << Quadtree{
                perimeter: AABB{
                        x: x + child_width
                        y: y + child_height
                        width: child_width
                        height: child_height
                }
                capacity: q.capacity
                depth: q.depth
                level: next_level
                particles: []AABB{}
                nodes: []Quadtree{len: 0, cap: 4}
        }
}

pub fn (mut q Quadtree) get_index(p AABB) []int {
        mut indexes := []int{}
        mut v_midpoint := q.perimeter.x + (q.perimeter.width / 2)
        mut h_midpoint := q.perimeter.y + (q.perimeter.height / 2)

        mut north := p.y < h_midpoint
        mut west := p.x < v_midpoint
        mut east := p.x + p.width > v_midpoint
        mut south := p.y + p.height > h_midpoint

        // top-right quad
        if north && east {
                indexes << 0
        }

        // top-left quad
        if west && north {
                indexes << 1
        }

        // bottom-left quad
        if west && south {
                indexes << 2
        }

        // bottom-right quad
        if east && south {
                indexes << 3
        }
        return indexes
}

[manualfree]
pub fn (mut q Quadtree) insert(p AABB) {
        mut indexes := []int{}

        if q.nodes.len > 0 {
                indexes = q.get_index(p)
                for k in 0 .. indexes.len {
                        q.nodes[indexes[k]].insert(p)
                }
                // unsafe { indexes.free() }
                return
        }
 
        q.particles << p
        
        if (q.particles.len > q.capacity) && (q.level < q.depth) {
                if q.nodes.len == 0 {
                        q.split()
                }
             
                for j in 0 .. q.particles.len {
                        indexes = q.get_index(q.particles[j])
                        for k in 0 .. indexes.len {
                                q.nodes[indexes[k]].insert(q.particles[j])
                        }
                }              
                q.particles = []
                // unsafe { indexes.free() }
        }
      
}

pub fn (mut q Quadtree) retrieve(p AABB) []AABB {
        mut indexes := q.get_index(p)
        mut detected_particles := q.particles

        if q.nodes.len > 0 {
                for j in 0 .. indexes.len {
                        detected_particles << q.nodes[indexes[j]].retrieve(p)
                }
        }
        return detected_particles
}