#*
    Demens Components
*#

// only inline fns if they are short, 1 line arrow fns
// otherwise, dont, leave it as a usual pure fn
// never prematurely optimize

// In demens, we dont care about the range as much as the precision

export Movement: [f16; 3]

// IDE has an extend Self annotation
Movement: extend {}

Position: [f16; 3]

// handle mouse clicks in terra

// UI in arcen
InitialUI: () {
    @arcen Flex[w="100%" h="100%"] {
        // black bg color to hide menu as its loading
        DemensLogo[fade_in=1s fade_out=3s pos=Center bg_color=Black size=Full]
        // note a scope by itself like {} is simply considered Rei
        // otherwise use an identifier like Box or @arcen
        @rei {}

        // menu should load behind the animation
        Menu
    }
}

GameState: enum {
    NewGame
    Save
}

Menu: (theme: Theme) {
    load_game = () => {}
    new_game = () => {
        // default settttttttinggggggs
        LoadState(NewGame)
    }

    // maybe load state/settings for themes?
    Play = () => @arcen {
        {
            in_play_menu?
            @arcen {Box[on_click=set_play_menu(true)] {"Play"}}
            :
            @arcen {
                Box[on_click=new_game] {"New Game"}
                Box[on_click=load_game] {"Load Game"}
                Box[on_click=set_play_menu(false)] {"<"}
            }
        }
    }

    @arcen Flex[flex_dir=Col p=Rem(10)] {
        Play
        Settings
    }
}

// Entity Packages

// NOTE: always a good idea to define your data in code I think
// like react
// and serialise if needed

Model: {
    default_path: String = "assets/"
    curr_model_matrix: ModelMatrix
    // maybe the + notation for quick tuples?
    // for Vec, maybe can make it stack based too with Vec::new_on_stack()
    // Array is always just array
    model: (Vec<Vertex>, Vec<Material>)

    animation: (&mut self Animation, dt: f16) {
        self.animation...
    }

    new: (path: String, use_default_path: bool = true) {
        // usually what happens is that the arrow fn is in .data and bound to the local var
        let load_glb = (path) => {
            std::graphics::glb::load(path).vertices_and_animations()
            // also std::net::json::load and parse
        }

        if use_default_path {
            // load the model
            let res = load(path).expect("Import Model Error: Not a valid GLB target...")

            Self {
                model: res.parse()
            }
        }
        else {
            // default constructor
            Self()
        }
    }
}

// common animations
Animation: enum {
    TravelAnimation
    DestroyAnimation
    AttackAnimation
}

Movement: (Position3D, Velocity3D, Acceleration3D)

Movement: extend {}

Animation: extend {
    // should be const
    const animate: (action: Action) -> Animation {
        match action {
            Run(speed) => {
                // return the movement animation
                TravelAnimation
            }
        }
    }
}

Agvn: u64

// note, you can extend lazily with lazy T?
// on an individual or global basis maybe
AgvnDrone: extend Health, Agvn, Movement, Model("AGVNDrone.glb") {
    travel_animation: (&mut self, dt: f16) -> ModelMatrix {
        self.model.animation(TravelAnimation, dt)
    }
}

// I think we should only do new() I think
// cause that has special behavior
// and is laziable?
// or other way...

// systems fns work a little differently...?
// or maybe you dont need to... for a world I meant
movement: (dt: f16, move: &mut Changed(Movement)...) {
    move.for_each(&mut m => {
        // you can only accelerate
        // based on current velocity and acceleration, update new position
        m.vel += m.accel * dt
        m.pos += m.vel * m.dt
    })
}

/*
    MAPS
*/

// cities
Building: {
    hitpoints: f16
    // pillaging sets hitpoints to 0
    pillaged: bool
    // even a pillage building belongs to a playerr
    belongs_to: &Faction
}

// I think its kinda fine to just have everything in one place
// and not categorised too deeply or really at all if not
// strictly needed
// like loose leaf notes organised by key: val
// and a few high level themes

// we extend civ6's system and have mini hexes where possible
// theres like 2000 hexes
// and randomly generated yields
// not all tiles are of equal size
// there are like 9 mini hexes per hex for extra buildings
// auto zoom in
// there are no turns
// instead everything is in real time
// troops have pretty slow movement at first
// why hexes? why not just squares?
// unlike civ6, AI is actually good and dont get any handicaps. Unlike civ6 you start off with more stuff and options, the place where you start off doesnt determine your success, merely your build schedule and things you want to start to exploit and explore and conquer for
// unlike civ6, barbarians are actually big deals now. And frequent everyone else and basically are loosely knit networks of people and tech that you can try to incorporate and exploit. There are no city states, but there are free emplacements and cities that you should try to conquer as soon as possible
// you start off with a pretty makeshift banner and evolve into something cool

// START OFF WITH:
// 1x coilgun squad
// 1x drone squad
// 2x worker squad

// you can build:
// - Military Buildings: Army HQ, Barracks, Military Airports (mini at first)
// - Combat Buildings: Bunker, Emplacements (against barbarians and stuff at first too), 
// - Basic Resource Gathering Buildings (without improvements that speed them up or make them efficient or allow advanced combination)
// - City Buildings: Government Buildings, Economics Centres, Diplomacy Centres/Embassies, Education Centres, Neighbourhoods, Entertainment Centres, Seaports, etc. Which increase potency of other buildings, provide all sorts of bonuses and etc. All buildings are autoconnected with a shortest path algorithm. Hexes are very good here
// - Transport Buildings: Rail, Airports, Shipyards. Increase the rate of resource gathering when built near them (like cities skylines)

// airports with airfields and 1 hanger -> more hangers -> more runways ==> more storage and higher resource gathering rates, higher troop deployment rates
// rail -> more parallel rails => higher resource gathering rates, troops to front line rates
// bridges -> more parallel roads => more units and resources can pass through at once

// you can build a mini HQ first, and only once per "area". It'll take some time to build
// unlike in civ6, a mine or resource gatherer gathers all resources that are "near" it. And most of the times resources are contiguous 2D areas
// like in CoH2, units can move continously be be setup in places, capture things, build buildings, etc
// most things dont take too long to build, and more workers can be placed on the task to speed it up
// to prevent annoyingness, there isnt golden ages or loyalty and crap
// just pillage, build ontop of and capture where possible

Building: enum {
    // farm
    Farm: enum => Outdoor | Indoor
    BarnHouse
    Silo
    // cities
    Skyscraper
    Apartment
    SuburbanHouse
    // industry
    Factory
    ProcessingPlant
    // usual
    Bridge
    // combat
    Bunker: {
        squad: &Squad
    }
    Waypoint
    Emplacement: enum {
        AAGun
        ATGun
    }
    SolarPanel: {
        efficiency: Percentage = 100%
    }
}

// one way is to just pattern match in one place, another way is to have the instances have the data

// set farm as an enum of Building
// Farm: extend Building {}

/*
    FACTIONS
*/

RedHunters: ()
IndustryMen: ()
Founders: ()
Vanguards: ()

/*
    RESOURCES
*/

Resource: {
    purity: Percentage

    // purification "buildings" are actually temporary things/investements that auto die off when the resource deposit is gone
    // or maybe civ6 where you just build the building ontop of it
    purify_building: () {
        match Self {
            Iron => SmeltingPlant
            Sand => Drege | Sifter
            Water => FiltrationPlant
        }
    }

    // on an air field, you can build a windmill or vacuum pump building
    // on a fertile field, you can build an outdoor farm (you basically have to at first)
    // on any sunny area or open area, you can build solar panels. Note depending on buildings close to it, it might get shadowed and its efficiency lowered
    // on a place with relatively low purity, say <50%, you can build a SmeltingPlant like in civ6
    // UNLIKE AOE, the building placement doesnt matter too much. Its more like civ6 where you command troops or worker units to build a building on a certain tile/tiles. Hexagonal by default, and not shown by default either. Every hexagon has a list of yields like civ6
    // unlike civ6, troops and workers are in real time
    miner: () -> Building {
        match Self {
            Iron | Carbon | Silicon | Aluminium | Copper | Alkali | Titanium | Uranium => Mine
            Food => Farm
            Sunlight => SolarPanel
            Water => Pump
            Air => Windmill | VacuumPump
        }
    }
}

Resource: enum {
    // metals/building materials/troop building and maintenance materials. Carbon can be refined into graphene and carbon fibre as well as nanotubes and buckyballs
    // iron can be refined into stainless steel, building steel, weapon steel, and all kinds of things
    // prob the most important element after sand (SiO2)
    // sand can be smelted into glass and concrete, used heavily in building materials and combat buildings such as bunkers
    // carbon is added to many things
    // purity is an important statistic in most mineral and resource deposits. The more pure, the more the yield for the energy expended to mine or collect it. If needed, you can build stuff to purify it further
    Iron
    Carbon
    Silicon
    Sand
    Aluminium
    Copper
    // rare (sodium, magnesium, lithium, and stuff)
    Alkali
    Titanium
    // food (from farms usually, first makeshift outdoor farms, then automated and then completely automatic indoor vertical farms). For pop and some for troops
    // making food usually requires energy (light), can be made from sunlight or any other energy. Also fertiliser, from the haber process (H and N), so basically water and air. Food usually means plants for fibre, protein, fats and minerals and lab grown protein and fats. Basically better and better food
    // autonomous vehicles dont require food but are expensive and hard to manage, not as effective early-mid game. They become very very good the later the game goes on...
    Food
    // energy (water for fusion and liquids for armour and troops). Mostly for buildings and some for troops. Air in windy regions for windmills and nitrogen and oxygen tanks (for all kinds of advanced tech)
    // bodies of running water can be used in hydroelectric dams, irrigation, many industrial processes. Kind of like cities skylines
    Uranium
    Sunlight
    Water
    Air
}

/*
    Units
*/

// workers have education levels 0-3
// education level 3 workers can build a bunch of things
// schools increase nationwide education levels for all units. You need to keep increasing the capacity and send the unit to school or train a unit there

// maybe add a Base keyword?

Makeshift: {
    squad_number: Size

    // either this or case classes with their own default arg for a super.field
    get_default_squad_number: () -> Size {
        match Self {
            Worker => 2
            Coilguns => 4
            Gatlers => 2
            Railguns => 2
            Carriers => 1
            Drones => 1
        }
    }

    // these are auto generated
    get_default_squad_number: (&self) -> Size => get_default_squad_number()
}

Makeshift: enum {
    Worker
    Coilguns
    Railguns
    Gatlers
    Carriers
    Drones
}

// NOTE, a macro works like this, you have a steam of tokens and your param is match tokens
// s: Ident...
