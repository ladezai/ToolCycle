function initUi()
    app.registerUi({ ["menu"] = "Cycle through tool size", ["callback"] = "cycle_size", ["accelerator"] = "<Shift><Alt>S"});
    app.registerUi({ ["menu"] = "Cycle through tools", ["callback"] = "cycle_tool", ["accelerator"] = "<Shift><Alt>T"});
    app.registerUi({ ["menu"] = "Cycle through palette's colors", ["callback"] = "cycle_color", ["accelerator"] = "<Shift><Alt>C"});
end

-- Color converion from an RGB u8 to a RGB hexadecimal, 
-- e.g. 255 255 255 -> ffffff.
function rgb_to_hex(r, g, b)
    local hex_string = string.format("%02x%02x%02x", 
                                tonumber(r,10), 
                                tonumber(g,10), 
                                tonumber(b,10))
    return tonumber(hex_string, 16)
end

-- Generates the palette file path depending on OS type.
function palette_path()
    local os_type = package.config:sub(1,1) == "\\" and "win" or "unix";
    if os_type == "unix" then
        return os.getenv("HOME") .. "/.config/xournalpp/palette.gpl";
    else
        -- TODO: add support for windows
        app.msgbox("Windows is not supported", {});
        return "";
    end
end

-- Check if a file exists 
function file_exists(file)
    local f = io.open(file, "rb");
    if f then 
        f:close();
    end
    return f ~= nil;
end

-- TODO: Add Docs
function load_color_palette(file, heading_length)
    -- Check if the color palette exists
    if not file_exists(file) then 
        app.msgbox("no default palette found!", {});
        return {};
    end
    
    local hexColors = {};
    local k = 1;
    -- TODO: clean this part.
    for line in io.lines(file) do 
        -- Skip the heading, read only the first three 
        -- tokens and store it into a table. Then, convert 
        -- the table to an unique hex value that represents 
        -- the color.
        if k >= heading_length then
            local i  = 1;
            -- read the non-heading line 
            local rgb_vals = {};
            for color in string.gmatch(line, "[^%s]+") do
                if i <= 3 then
                    table.insert(rgb_vals, i, color);
                end
                i = i + 1
            end
            -- conversion of the non-heading line
            local hexcolor = rgb_to_hex(rgb_vals[1], rgb_vals[2], rgb_vals[3]);
            table.insert(hexColors, hexcolor);
        end
        k = k + 1;
    end
    return hexColors
end

-- Code to interate through the more common tools
local toolList = {
    "ACTION_TOOL_PEN", -- select pen
    "ACTION_TOOL_ERASER", -- select eraser
    "ACTION_TOOL_HIGHLIGHTER", -- select highlighter
    "ACTION_TOOL_SELECT_REGION", -- select region tool
}

local toolSize = {
    {"fine", "ACTION_SIZE_FINE"},
    {"medium", "ACTION_SIZE_MEDIUM"},
    {"thick", "ACTION_SIZE_THICK"}
}

-- store the palette colors in a table
local globalPath    = palette_path(); 
local paletteColors = load_color_palette(globalPath, 4);

local currentTool   = 1;
local currentSize   = 1;
local currentColor  = 1;

function cycle_tool() 
    if (currentTool < #toolList) then
        currentTool = currentTool + 1;
    else
        currentTool = 1;
    end
    -- select the new tool
    app.uiAction({["action"]=toolList[currentTool]});

    -- change the current size to the one in the counter, 
    -- in this way the unified counter is well-behaved 
    -- with respect to all tools.
    app.uiAction({["action"]=toolSize[currentSize][2]});
end

function cycle_size()
    if (currentSize < #toolSize) then
        currentSize = currentSize + 1;
    else
        currentSize = 1;
    end
    -- change size of the tool
    app.uiAction({["action"]=toolSize[currentSize][2]});
end

function cycle_color()
    if (currentColor < #paletteColors) then
        currentColor = currentColor + 1;
    else
        currentColor = 1;
    end
    -- change colors accordingly to the palette given
    app.changeToolColor({["color"]=paletteColors[currentColor], ["selection"] = true});
end


