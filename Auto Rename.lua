--[[
Auto Rename
created by Nizar / version 1.0
contact: http://twitter.com/nizarneezR

Usage:

- Open the Fusion page 
- Run this script from DaVinci Resolve's dropdown menu (Workspace > Scripts)
- This will automatically rename all unnamed "MediaIn", "Background", "Text+" and "Text 3D" nodes to logical display names

- This works best if bound to a hotkey! (open hotkey settings with CTRL+ALT+K)


Install:

- Copy this .lua-file into the folder "%appdata%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Comp"

--]]

-- Subprocesses
-- [Media In-Nodes]

function rename_mediain_node(tool)
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

-- [Background Nodes]

BG_NODE_PREFIX = ""
BG_NODE_SUFFIX = ""

-- Change these if you want to add prefixes or suffixes to the way Background nodes are renamed
--
-- If you want names like "bg_Red_node", "bg_Blue_node", ...
-- change BG_NODE_PREFIX = "bg_" and BG_NODE_SUFFIX = "_node"
--
-- or keep them empty for names like "Red","Blue",...


COLORS = {White={1.0,1.0,1.0}, Silver={0.75,0.75,0.75}, Gray={0.5,0.5,0.5}, Black={0.0,0.0,0.0}, Red={1.0,0.0,0.0}, Maroon={0.5,0.0,0.0}, Yellow={1.0,1.0,0.0}, Olive={0.5,0.5,0}, Lime={0.0,1.0,0.0}, Green={0.0,0.5,0.0}, Cyan={0.0,1.0,1.0}, Teal={0.0,0.5,0.5}, Blue={0.0,0.0,1.0}, Navy={0.0,0.0,0.5}, Magenta={1.0,0.0,1.0}, Purple={0.5,0.0,0.5}, Pink={1.0,0.75,0.8}, OrangeRed={1.0,0.27,0.0}, Orange={1.0,0.55,0.0},Gold={1.0,0.84,0.0}, Brown={0.55,0.27,0.07}}

-- Colors are based on CSS4 colors (core colors + some extras)
-- https://en.wikipedia.org/wiki/Web_colors

function rename_background_node(tool)
	if tool:GetAttrs("TOOLS_RegID") == "Background" then
		--todo handle BG.Type (solid, gradient)?
		local r,g,b,a = tool.TopLeftRed[comp.CurrentTime], tool.TopLeftGreen[comp.CurrentTime], tool.TopLeftBlue[comp.CurrentTime], tool.TopLeftAlpha[comp.CurrentTime]
		
		local est_color = guess_color(r,g,b,a)
		local new_node_name = BG_NODE_PREFIX .. est_color .. BG_NODE_SUFFIX
		
		tool:SetAttrs({TOOLS_Name = new_node_name})
	end
end

function guess_color(r,g,b,a)
	if a == 0 then
		return "Transparent"
	end
	
	similarity_table = {} --color_name:similarity_to_input_color
	for color_name, color_rgb_table in pairs(COLORS) do
		similarity_table[color_name] = similarity(color_rgb_table[1], color_rgb_table[2], color_rgb_table[3], r,g,b)
	end
	
	local est_color = get_best_match_from_sim_table(similarity_table)
	
	if a < 1 then
		return est_color .. "_Transparent"
	else
		return est_color
	end
end

function get_best_match_from_sim_table(t)
	local key = next(t)
	local minv = t[key]

	for k, v in pairs(t) do
		if t[k] < minv then
			key, minv = k, v
		end
	end
	
	return key
end

function similarity(r1,g1,b1,r2,g2,b2)
	--1 is color in COLORS, 2 is color in bg node
	return _cielab_similarity(r1,g1,b1,r2,g2,b2)
end

function _cielab_similarity(r1,g1,b1,r2,g2,b2)
	local x1,y1,z1 = sRGBtoLab(r1,g1,b1)
	local x2,y2,z2 = sRGBtoLab(r2,g2,b2)
	
	--taxi-cab distance of chroma+L
	return math.sqrt((y1-y2)^2 + (z1-z2)^2) + math.abs(x1-x2)
end


-- some other similarity measurements that were tested earlier, but were not as accurate as CIELAB

--[[
function _cosinesimilarity(r1,g1,b1,r2,g2,b2)
	--apply weights for human perception
	r1 = r1 * 0.3
	r2 = r2 * 0.3
	g1 = g1 * 0.59
	g2 = g2 * 0.59
	b1 = b1 * 0.11
	b2 = b2 * 0.11
	
	--cosine similarity
	local dp = (r1*r2) + (g1*g2) + (b1*b2)
	local len_a = math.sqrt(r1^2 + g1^2 + b1^2) 
	local len_b = math.sqrt(r2^2 + g2^2 + b2^2) 
	
	return dp/(len_a*len_b)
end

function _euclidiandistance(r1,g1,b1,r2,g2,b2)
	return math.sqrt(0.3*(r1-r2)^2 + 0.59*(g1-g2)^2 + 0.11*(b1-b2)^2)
end

function _hue_similarity(r1,g1,b1,r2,g2,b2)
	local vivid = require('vivid')
	local h1,_s1,_v1, _a1 = vivid.RGBtoHSV(r1,g1,b1, 1.0)
	local h2,_s2,_v2, _a2 = vivid.RGBtoHSV(r2,g2,b2, 1.0)
	
	return math.min(math.abs(h1-h2), 1-math.abs(h1-h2))
end
]]--

function sRGBtoLab(r,g,b)
	-- adapted from vivid.lua
	-- https://github.com/WetDesertRock/vivid
  --(Observer = 2°, Illuminant = D65)

  if r > 0.04045 then
    r = ((r+0.055)/1.055)^2.4
  else
    r = r/12.92
  end
  if g > 0.04045 then
    g = ((g+0.055)/1.055)^2.4
  else
    g = g/12.92
  end
  if b > 0.04045 then
    b = ((b+0.055)/1.055)^2.4
  else
    b = b/12.92
  end

  r = r*100
  g = g*100
  b = b*100

  local x = r * 0.4124 + g * 0.3576 + b * 0.1805
  local y = r * 0.2126 + g * 0.7152 + b * 0.0722
  local z = r * 0.0193 + g * 0.1192 + b * 0.9505


  local refx,refy,refz = 95.047,100.000,108.883
  
  x,y,z = x/refx,y/refy,z/refz
  
  if x > 0.008856 then
    x = x^(1/3)
  else
    x = (7.787*x) + (16/116)
  end
  if y > 0.008856 then
    y = y^(1/3)
  else
    y = (7.787*y) + (16/116)
  end
  if z > 0.008856 then
    z = z^(1/3)
  else
    z = (7.787*z) + (16/116)
  end

  L = (116*y) - 16
  a = 500*(x-y)
  b = 200*(y-z)
  return L,a,b
end

-- [Text Nodes]

NODE_PREFIX_TEXTPLUS = "Text_"
NODE_PREFIX_TEXT3D = "Text3D_"

-- Change these if you want to change the prefixes or suffixes added to the way Text nodes are renamed


function rename_textplus_node(tool)
	if tool:GetAttrs("TOOLS_RegID") == "TextPlus" or tool:GetAttrs("TOOLS_RegID") == "Text3D" then
		local styledtext = tool.StyledText[comp.CurrentTime]
		
		if styledtext ~= "" then
			local new_node_name = shorten_text_node_name(styledtext)
			
			if tool:GetAttrs("TOOLS_RegID") == "TextPlus" then
				new_node_name = NODE_PREFIX_TEXTPLUS .. new_node_name
			
			
			elseif tool:GetAttrs("TOOLS_RegID") == "Text3D" then
				new_node_name = NODE_PREFIX_TEXT3D .. new_node_name
			end
			
			tool:SetAttrs({TOOLS_Name = new_node_name})
		end
	end
end


function shorten_text_node_name(styledtext)
	local words = {}
	
	for matchgroup in string.gmatch(styledtext, "%S+") do
		words[#words+1] = matchgroup
	end
	
	
	if(#words == 1) then
		return styledtext
	end
	
	if(#words >= 2) then
		return(words[1] .. "_" .. words[2])
	end
end

-- [main loop]

function main()
	tools = fusion:GetCurrentComp():GetToolList()
	
	for _,tool in ipairs(tools) do
		local _tool_id = tool:GetAttrs("TOOLS_RegID")
		local _tool_displayname = tool:GetAttrs().TOOLS_Name
		
		if((_tool_id == "MediaIn") and string.find(_tool_displayname, "MediaIn")) then
			rename_mediain_node(tool)
		
		elseif(_tool_id == "Background") then
			if(string.find(_tool_displayname, "Background") or string.find(_tool_displayname, "Transparent")) then
				rename_background_node(tool)
				break
			end
			for color,_ in pairs(COLORS) do
				if(_tool_displayname == BG_NODE_PREFIX .. color .. BG_NODE_SUFFIX) then
					rename_background_node(tool)
					break
				end
			end
		
		elseif((_tool_id == "TextPlus") or (_tool_id == "Text3D")) then
			if(string.find(_tool_displayname, NODE_PREFIX_TEXTPLUS) or string.find(_tool_displayname, NODE_PREFIX_TEXT3D) or string.find(_tool_displayname, "Text")) then
				print(_tool_displayname)
				rename_textplus_node(tool)
			end
		end
	end
end

main()