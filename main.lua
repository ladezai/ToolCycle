function initUi()
    app.registerUi({ ["menu"] = "Cycle through tool size", ["callback"] = "cycle_size", ["accelerator"] = "<Shift><Alt>S"});
    app.registerUi({ ["menu"] = "Cycle through tools", ["callback"] = "cycle_tool_next", ["accelerator"] = "<Shift><Alt>T"});
    app.registerUi({ ["menu"] = "Cycle through tools", ["callback"] = "cycle_tool_prev", ["accelerator"] = "<Shift><Control>T"});
    app.registerUi({ ["menu"] = "Cycle through palette's colors", ["callback"] = "cycle_color_next", ["accelerator"] = "<Shift><Alt>C"});
    app.registerUi({ ["menu"] = "Cycle through palette's colors", ["callback"] = "cycle_color_prev", ["accelerator"] = "<Shift><Control>C"});
end

-- Color converion from an RGB u8 to a RGB hexadecimal, 
-- e.g. 255 255 255 -> ffffff.
function rgb_to_hex(r, g, b)
    local hex_string = string.format("%02x%02x%02x", 
                                tonumber(r,10), 
                                tonumber(g,10), 
                                tonumber(b,10));
    return tonumber(hex_string, 16);
end

-- Generates the palette file path depending on OS type.
function get_palette_path()
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

-- Reads a GIMP palette file and returns a table of the hexadecimal number 
-- representing the colors in the given file. 
function load_color_palette(file, heading_length)
    -- Check if the color palette exists
    if not file_exists(file) then 
        app.msgbox("no default palette found!", {});
        return {};
    end
    
    local hex_colors    = {};
    local line_reader   = io.lines(file);

    -- Skip the heading, read only the first three 
    -- tokens and store it into a table. 
    for i = 1, heading_length-1 do
        line_reader();
    end
    
    -- The non-heading part of the file is being translated into
    -- hexadecimal values representing colors.
    for line in line_reader do 
        local tokens   = {};
        local words    = string.gmatch(line, "[^%s]+");

        -- read only the first 3 matches.
        for i = 1, 3 do
            table.insert(tokens, words());
        end 

        -- conversion of the 3 matches to a hex-color
        local hex_color = rgb_to_hex(tokens[1], tokens[2], tokens[3]);
        table.insert(hex_colors, hex_color);
    end
    return hex_colors;
end

-- Common tools
local toolList = {
    "ACTION_TOOL_PEN", -- select pen
    "ACTION_TOOL_ERASER", -- select eraser
    "ACTION_TOOL_HIGHLIGHTER", -- select highlighter
    "ACTION_TOOL_SELECT_REGION", -- select region tool
    "ACTION_TOOL_HAND", -- hand to move
};

-- Common tool sizes
local toolSize = {
    {"thin", "ACTION_SIZE_FINE"},
    {"medium", "ACTION_SIZE_MEDIUM"},
    {"thick", "ACTION_SIZE_THICK"},
};

local fromToolSizeNameToKey = { ["thin"]= 1, ["medium"] = 2, ["thick"] = 3 };

-- store the palette colors in a table
local globalPath    = get_palette_path(); 
local paletteColors = load_color_palette(globalPath, 4);

local currentTool   = 1;
local currentSize   = -1;
local currentColor  = 1;

function cycle_tool_next() 
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
    if (currentSize > 0) then 
        app.uiAction({["action"]=toolSize[currentSize][2]});
    else
        -- in case not initialized cycle n times to get the same value
        -- of size.
        for i = 1, #toolSize do
            cycle_size()
        end
    end
end

function cycle_tool_prev() 
    if (currentTool > 1) then
        currentTool = currentTool - 1;
    else
        currentTool = #toolList;
    end

    -- select the new tool
    app.uiAction({["action"]=toolList[currentTool]});

    -- change the current size to the one in the counter, 
    -- in this way the unified counter is well-behaved 
    -- with respect to all tools.
    if (currentSize > 0) then 
        app.uiAction({["action"]=toolSize[currentSize][2]});
    else
        -- in case not initialized cycle n times to get the same value
        -- of size.
        for i = 1, #toolSize do
            cycle_size()
        end
    end
end


function cycle_size()
    -- initialize on start-up
    if (currentSize < 0) then
        local activeInfo = app.getToolInfo("active");
        currentSize      = fromToolSizeNameToKey[tostring(activeInfo["size"]["name"])];
    end

    if (currentSize < #toolSize) then
        currentSize = currentSize + 1;
    else
        currentSize = 1;
    end
    -- change size of the tool
    app.uiAction({["action"]=toolSize[currentSize][2]});
end

function cycle_color_next()
    if (currentColor < #paletteColors) then
        currentColor = currentColor + 1;
    else
        currentColor = 1;
    end
    -- change colors according to the given palette
    app.changeToolColor({["color"]=paletteColors[currentColor], ["selection"] = true});
end

function cycle_color_prev()
    if (currentColor > 1) then
        currentColor = currentColor - 1;
    else
        currentColor = #paletteColors;
    end
    -- change colors according to the given palette
    app.changeToolColor({["color"]=paletteColors[currentColor], ["selection"] = true});
end


