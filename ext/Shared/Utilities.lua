class('Utilities');

require('__shared/Config');

function Utilities:__init()
	-- nothing to do
end

function Utilities:getCameraPos(player, isTarget)
	local returnVec = Vec3(0,0,0);
	local cameraVec = player.input.authoritativeCameraPosition:Clone();
	
	if cameraVec.z ~= 0 then
		returnVec = player.soldier.worldTransform.forward* cameraVec.z + player.soldier.worldTransform.left * cameraVec.x + player.soldier.worldTransform.up * cameraVec.y;
		--print(returnVec)

		if isTarget then
			if Config.aimForHead then
				if player.soldier.pose == CharacterPoseType.CharacterPoseType_Stand then
					returnVec.y = returnVec.y - 0.1;
				elseif player.soldier.pose == CharacterPoseType.CharacterPoseType_Crouch then
					returnVec.y = returnVec.y - 0.05;
				else
					returnVec.y = returnVec.y - 0.05;
				end
			else
				if player.soldier.pose == CharacterPoseType.CharacterPoseType_Stand then
					returnVec.y = returnVec.y - 0.4;
				elseif player.soldier.pose == CharacterPoseType.CharacterPoseType_Crouch then
					returnVec.y = returnVec.y - 0.2;
				else
					returnVec.y = returnVec.y - 0.05;
				end
			end
		end
	else
		returnVec = Vec3(0.03 ,self:getTargetHeight(player.soldier, isTarget), 0.03);
	end
	
	return returnVec;
end

function Utilities:getTargetHeight(soldier, isTarget)
	local camereaHight = 0;

	if not isTarget then
		camereaHight = 1.6; --bot.soldier.pose == CharacterPoseType.CharacterPoseType_Stand
		
		if soldier.pose == CharacterPoseType.CharacterPoseType_Prone then
			camereaHight = 0.3;
		elseif soldier.pose == CharacterPoseType.CharacterPoseType_Crouch then
			camereaHight = 1.0;
		end
		
	elseif isTarget and Config.aimForHead then
		camereaHight = 1.50; --bot.soldier.pose == CharacterPoseType.CharacterPoseType_Stand
		
		if soldier.pose == CharacterPoseType.CharacterPoseType_Prone then
			camereaHight = 0.25;
		elseif soldier.pose == CharacterPoseType.CharacterPoseType_Crouch then
			camereaHight = 1;
		end
		
	else --aim a little lower
		camereaHight = 1.2; --bot.soldier.pose == CharacterPoseType.CharacterPoseType_Stand - reduce by 0.4
		
		if soldier.pose == CharacterPoseType.CharacterPoseType_Prone then
			camereaHight = 0.25; -- don't reduce
		elseif soldier.pose == CharacterPoseType.CharacterPoseType_Crouch then
			camereaHight = 0.8; -- reduce by 0.2
		end
		
	end

	return camereaHight;
end

function Utilities:isBot(name)
	local isBot = false;
	
	for  index, botname in pairs(BotNames) do
		if name == botname then
			isBot = true;
			break;
		end
		
		if index > MAX_NUMBER_OF_BOTS then
			break;
		end
	end
	
	return isBot;
end

function Utilities:getEnumName(enum, value)
	for k,v in pairs(getmetatable(enum)['__index']) do
		if (v == value) then
			return k;
		end
	end
	
	return nil;
end

-- do not use on numerically indexed tables, only tables with string keys
-- this is shallow merge, does not recurse deeper than one level
function Utilities:mergeKeys(originalTable, newData)
   for k,v in pairs(newData) do
      originalTable[k] = v;
   end 
 
   return originalTable;
end

function Utilities:dump(o, format, maxLevels, level)
	local tablevel			= '';
	local tablevellessone	= '';
	local newline			= '';
	maxLevels				= maxLevels or -1;
	level					= level or 1;
	
	if format then
		tablevel			= string.rep("\t", level);
		tablevellessone		= string.rep("\t", math.max(level-1, 0));
		newline				= "\n";
	end

	if o == nil then
		return 'nil';
	end
	
	if type(o) == 'table' then
		if (maxLevels == -1 or level <= maxLevels) then
			local s = tostring(o) .. ' -> { ' .. newline;
			
			for k,v in pairs(o) do
				if type(k) ~= 'number' then
					k = '"'..k..'"';
				end
				
				s = s .. tablevel .. '['..k..'] = ' .. g_Utilities:dump(v, format, maxLevels, level+1) .. ',' .. newline;
			end
			
			return s .. tablevellessone .. '}';
		else
			return '{ '.. tostring(o) .. ' }';
		end
	else
		return tostring(o);
	end
end

function string:split(sep)
	local sep, fields	= sep or ':', {};
	local pattern		= string.format("([^%s]+)", sep);

	self:gsub(pattern, function(c) fields[#fields + 1] = c end);

	return fields;
end

function requireExists(module)
    local function reference(module)
        require(module)
    end
	
    res = pcall(reference, module);
	
    if not(res) then
        -- Not found.
    end
end

-- Singleton.
if g_Utilities == nil then
	g_Utilities = Utilities();
end

return g_Utilities;