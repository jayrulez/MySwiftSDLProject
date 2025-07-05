import SDL3

// Initialize SDL3
SDL_Init(0x00000020) // SDL_INIT_VIDEO
defer { SDL_Quit() }

// Create window  
let window = SDL_CreateWindow("My Window", 800, 600, 0x0000000000000020)
defer { SDL_DestroyWindow(window) }

// Event loop
var event = SDL_Event()
var running = true

while running {
    while SDL_PollEvent(&event) {
        let eventType = SDL_EventType(Int32(event.type))
        if eventType == SDL_EVENT_QUIT {
            running = false
        }
    }
    SDL_Delay(16)
}