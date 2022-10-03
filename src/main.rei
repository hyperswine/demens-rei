# THIS FILE DEFINES YOUR MAIN FUNCTION'S NAMESPACE

// executable entry point (after runtime initialisation)
main: () -> Status {
    println("Hello, World!")
}

// empty pure object
World: ()

// extension block
World: extend {
    // system fn's are called on all instances
    globalise: system () => println("The world just got bigger")
}

// unit test
@test
globalise_world: () {
    // for pure objects, simply returns the obj itself. For data objects, simply the default constructor
    let old_world = World()
    let new_world = World()
    // call World's associated system fn to operate on all World instances
    World::globalise()
}
