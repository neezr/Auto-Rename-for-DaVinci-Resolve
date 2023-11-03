-- ~ Auto-Rename MediaIn to file name ~
-- created by nizar / version 1.1
-- contact: http://twitter.com/nizarneezR

-- Usage:
-- Open the Fusion page 
-- Run this script from DaVinci Resolve's dropdown menu (Workspace > Scripts)
-- This will automatically rename all unnamed MediaIn-nodes in a Fusion composition to their respective file names

-- This works best if bound to a hotkey (open hotkey settings with CTRL+ALT+K)

-- Install:
-- Copy this .lua-file into the folder "%appdata%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp"

comp = fusion:GetCurrentComp()

tools = comp:GetToolList()

for _, tool in ipairs(tools) do
	if string.find(tool:GetAttrs().TOOLS_Name, "MediaIn") then
		new_node_name = tool:GetAttrs().TOOLS_Clip_Name
		
		if string.find(new_node_name, ".") then --remove file extensions
			final_dot_index = (new_node_name:reverse()):find("%.")
			new_node_name = string.sub(new_node_name,1,#new_node_name-final_dot_index)
		end
		
		if new_node_name:match("^%d+$") then --add prefix to purely numeric file names
			new_node_name = "_" .. new_node_name
		end
		
		tool:SetAttrs({TOOLS_Name = new_node_name})
	end
end
