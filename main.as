bool RenderWindow = true;
bool IsSpeedAvailable = false;
int windowFlags = UI::WindowFlags::NoTitleBar | UI::WindowFlags::NoCollapse | UI::WindowFlags::NoDocking | UI::WindowFlags::NoScrollbar | UI::WindowFlags::AlwaysAutoResize;
int SpeedometerFontNVG;
UI::Font@ SpeedometerFontIG;

enum UIRenderer {
    NVG = 0,
    ImGui = 1
}

void renderFont(bool push)
{
    if (push) {
        UI::PushFont(SpeedometerFontIG);
    } else {
        UI::PopFont();
    }
}

void Main() 
{
    SpeedometerFontNVG = nvg::LoadFont("Segment7-4Gml.otf");
    @SpeedometerFontIG = UI::LoadFont("Segment7-4Gml.otf", 72);
}

void RenderMenu() 
{
    if (UI::MenuItem("\\$d3f" + Icons::Flask + " \\$zTMUF Speedometer")) {
        RenderWindow = !RenderWindow;
    } 
}

void Render()
{
    if (RenderWindow) 
    {
        try {
            // 3.6f is the conversion factor from m/s to km/h
            int speed = int(VehicleState::GetVis(GetApp().GameScene, VehicleState::GetViewingPlayer()).AsyncState.FrontSpeed * 3.6f);
            
            // stylistic choices
            if (speed < 0)
            {
                speed = -speed;
            }
            if (speed == 998)
            {
                speed = 999;
            }

            // calculate the number of spaces to add to the speed to make sure it's always centered
            string spaces = "";
            if (speed > 99) 
            {
                spaces = "";
            } 
            else if (speed > 9 && speed < 100) 
            {
                spaces = " ";
            }
            else if (speed >= 0 && speed < 10)
            {
                spaces = "  ";
            }
            if(s_renderer == UIRenderer::NVG) {
                // TODO: learn how to use nvg::TextAlign() to align the text, this bs cannot continue
                nvg::BeginPath();

                nvg::FontSize(72);
                nvg::FontFace(SpeedometerFontNVG);
                
                vec2 size = nvg::TextBounds(spaces + speed);

                // seperate black text for shadow
                if (s_shadow) 
                {
                    nvg::FillColor(vec4(0, 0, 0, 1));
                    nvg::Text(Draw::GetWidth() - size.x, Draw::GetHeight() - 3, spaces + speed);
                }

                // regular text
                nvg::FillColor(s_color);
                nvg::Text(Draw::GetWidth() - (size.x + 3), Draw::GetHeight() - 6, spaces + speed);

                nvg::ClosePath();
            } else {
                UI::Begin(" ", windowFlags);
                renderFont(true);
                UI::PushStyleColor(UI::Col::Text, s_color);
                UI::Text(spaces + tostring(speed));
                UI::PopStyleColor();
                renderFont(false);
                UI::End();
            }
        } catch {  }
    }    
}