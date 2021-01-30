class('Weapon');

function Weapon:__init(name, extension, unlocks, damage, bulletSpeed, isShotgun, fireCycle, pauseCycle)
	self.name		= name;
	self.extension	= extension;
	self.unlocks 	= unlocks;
	self.damage		= damage;
	self.bulletSpeed= bulletSpeed;
	self.isShotgun	= isShotgun;
	self.fireCycle	= fireCycle;
	self.pauseCycle	= pauseCycle;
end

function Weapon:getResourcePath(unlock)
	local ext = ""
	local unl = ""
	if unlock ~= nil then
		unl = "_"..unlock;
	end
	if self.extension ~= '' then
		ext = self.extension.."_"
	end

	return	"Weapons/"..ext..self.name.."/U_"..self.name..unl;
end

function Weapon:getAllAttachements()
	local attachmentList = {}
	for _, attachment in pairs(self.unlocks) do
		table.insert(attachmentList, self:getResourcePath(attachment));
	end
	return attachmentList;
end

return Weapon;