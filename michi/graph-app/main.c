#include <string.h>

#include <raylib.h>

#include "graph.h"

int main(int argc, char** argv)
{
    // Initialization
    const int screenWidth  = 960;
    const int screenHeight = 540;

    InitWindow(screenWidth, screenHeight, "Graph Test Prototype");

    SetTargetFPS(60);
    // ToggleFullscreen();
    int scr_width  = GetScreenWidth();
    int scr_height = GetScreenHeight();
    SetWindowSize(scr_width, scr_height);

    /* Graph API */
    Graph graph;
    graph_create(&graph, 12);
    graph_print(&graph);

    // Main loop
    while ( !WindowShouldClose() ) // Detect window close button or ESC key
    {
        bool left  = false;
        bool right = false;

        if ( IsKeyDown(KEY_A) )
        {
            left = true;
        }
        if ( IsKeyDown(KEY_D) )
        {
            right = true;
        }

        BeginDrawing();

        ClearBackground((Color){ 90, 100, 255, 0xFF });

        static const char* text      = "Testing if this works.";
        static const int   font_size = 30;
        int                text_len  = strlen(text);
        DrawText(text, scr_width / 2 - (text_len * (font_size / 2)) / 2, scr_height / 2, font_size, BLACK);
        if ( left ) DrawText("LEFT", 10, 10, 50, BLACK);
        if ( right ) DrawText("RIGHT", scr_width - 200, 10, 50, BLACK);

        EndDrawing();
    }

    // Shutdown
    CloseWindow(); // Close window and OpenGL context

    return 0;
}
