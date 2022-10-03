#*
    DEMENS
*#

main: () -> Status {
    terra3d::run()
}

Health: f16

// 10,000 entities in a world. If you want more, create more worlds
const MAX_SIZE = 10000

// defined in t3d
World: {
    damage: system (&self, health: &mut Health, damage: () -> f16) {
        health = clamp(0, health - damage())
    }

    # create a new entity in the world with a set of component instances
    new_entity: (&mut self, components: Component...) -> Entity {
        let res = Entity(components)
        self.register(res)

        res
    }

    register: (&mut self, entity: Entity) {
        self.entities.push(entity)
    }

    entities: [Entity; MAX_SIZE]
}

// when something with hp gets "hit" by "something"
// that something gets a () -> f16 based on the atk
