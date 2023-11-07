function initUi()
    app.registerUi({ ["menu"] = "Cycle through tool size", ["callback"] = "cycle_size", ["accelerator"] = "<Alt>S"});

    app.registerUi({ ["menu"] = "Cycle through tools", ["callback"] = "cycle_tools", ["accelerator"] = "<Alt>T"});
    print("Example plugin registered\n");
end

-- Code to interate through the more common tools
local toolList = {
    {"pen", "ACTION_TOOL_PEN"}, -- select pen
    {"eraser", "ACTION_TOOL_ERASER"}, -- select eraser
    {"highlighter", "ACTION_TOOL_HIGHLIGHTER"}, -- select highlighter
    {"select_region", "ACTION_TOOL_SELECT_REGION"}, -- select region tool
}

local currentTool = 1;

function cycle_tools() 
    if (currentTool < #toolList) then
        currentTool = currentTool + 1;
    else
        currentTool = 1;
    end
    app.uiAction({["action"]=toolList[currentTool][2]});
end

-- TODO: not working!
local toolSize = {
    {"fine", "medium"},
    {"medium", "thick"},
    {"thick", "very thick"},
    {"very thick", "fine"}
}

function cycle_size()
    local penInfo = app.getToolInfo("pen");
    local size = penInfo["size"]["name"];
    local newSize = toolSize[size][2];
    -- change size of the pen
    app.uiAction({["action"]=toolList[1][2], ["size"]=newSize});
    --penInfo["size"] = newSize;
end


