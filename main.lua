function initUi()
    app.registerUi({ ["menu"] = "Cycle through tool size", ["callback"] = "cycle_size", ["accelerator"] = "<Shift><Alt>S"});

    app.registerUi({ ["menu"] = "Cycle through tools", ["callback"] = "cycle_tools", ["accelerator"] = "<Shift><Alt>T"});
end

-- Code to interate through the more common tools
local toolList = {
    {"pen", "ACTION_TOOL_PEN"}, -- select pen
    {"eraser", "ACTION_TOOL_ERASER"}, -- select eraser
    {"highlighter", "ACTION_TOOL_HIGHLIGHTER"}, -- select highlighter
    {"select_region", "ACTION_TOOL_SELECT_REGION"}, -- select region tool
}

local toolSize = {
    {"very fine", "ACTION_SIZE_VERY_FINE"},
    {"fine", "ACTION_SIZE_FINE"},
    {"medium", "ACTION_SIZE_MEDIUM"},
    {"thick", "ACTION_SIZE_THICK"},
    {"very thick", "ACTION_SIZE_VERY_THICK"},
}

local currentTool = 1;
local currentSize = 1;

function cycle_tools() 
    if (currentTool < #toolList) then
        currentTool = currentTool + 1;
    else
        currentTool = 1;
    end
    -- select the new tool
    app.uiAction({["action"]=toolList[currentTool][2]});

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


