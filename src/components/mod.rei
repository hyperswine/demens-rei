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
