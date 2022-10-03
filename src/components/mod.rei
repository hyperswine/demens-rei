#*
    Demens Components
*#

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
