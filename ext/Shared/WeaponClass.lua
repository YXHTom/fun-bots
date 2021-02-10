class('Weapon');

function Weapon:__init(name, extension, unlocks, type, fullResource)
	self.name		= name;
	self.extension	= extension;
	self.unlocks 	= unlocks;
	self.type		= type;
	self.fullResource = fullResource;

	self.damage		= 0;
	self.bulletSpeed= 0;
	self.bulletDrop = 0;
	self.fireCycle	= 0;
	self.pauseCycle	= 0;
	self.reload		= 0;
	self.delayed	= false;
	self.needvalues	= true;

	Events:Subscribe('Level:Loaded', self, self.OnLevelLoaded);
end

function Weapon:setStatsValues(damage, bulletSpeed, bulletDrop, reload, fireCycle, pauseCycle, delayed)
	self.damage		= damage;
	self.bulletSpeed= bulletSpeed;
	self.bulletDrop = bulletDrop;
	self.fireCycle	= fireCycle;
	self.pauseCycle	= pauseCycle;
	self.reload		= reload;
	self.delayed	= delayed;
	self.needvalues = false;
end

function Weapon:OnLevelLoaded()
	if (self.needvalues) then
		self:learnStatsValues()
	end
end

function Weapon:learnStatsValues()
	local success = false
	local blueprint = nil
	local fireData = nil
	local aiData = nil
	local bulletData = nil

	blueprint, success = g_EbxEditUtils:GetWritableInstance(self:getResourcePath())
	if (not success) then print('No blueprint for: '..self.name) return end
	fireData, success = g_EbxEditUtils:GetWritableContainer(blueprint, 'Weapon.Object.WeaponFiring.PrimaryFire')
	if (not success) then print('No fireData for: '..self.name) return end
	aiData, success = g_EbxEditUtils:GetWritableContainer(blueprint, 'Weapon.Object.aiData')
	if (not success) then print('No aiData for: '..self.name) return end
	bulletData, success = g_EbxEditUtils:GetWritableContainer(fireData, 'shot.ProjectileData')
	if (not success) then print('No bulletData for: '..self.name) return end

	print(self.name..': '..tostring(aiData.name))

	self.damage 		= bulletData.startDamage
	self.bulletSpeed 	= fireData.shot.initialSpeed.z
	self.bulletDrop 	= bulletData.gravity
	self.fireCycle 		= aiData.maxBurstCoolDownTime
	self.pauseCycle 	= (aiData.maxBurstCoolDownTime + aiData.minBurstCoolDownTime) / 2
	self.reload			= fireData.fireLogic.reloadTime;
	self.delayed		= fireData.fireLogic.boltAction.forceBoltActionOnFireTrigger or fireData.ammo.magazineCapacity >= 80
	self.needvalues 	= false
end

function Weapon:getResourcePath(unlock)
	local unl = ""
	if self.fullResource == nil then
		local ext = ""
		if unlock ~= nil then

			if (string.starts(unlock, 'Weapons/Common/')) then
				return unlock
			end

			unl = "_"..unlock;
		end
		if self.extension ~= '' then
			ext = self.extension.."_"
		end

		return	"Weapons/"..ext..self.name.."/U_"..self.name..unl;
	else
		if unlock ~= nil then

			if (string.starts(unlock, 'Weapons/Common/')) then
				return unlock
			end

			unl = "_"..unlock;
		end
		return self.fullResource..unl;
	end
end

function Weapon:getAllAttachements()
	local attachmentList = {}
	for _, attachment in pairs(self.unlocks) do
		table.insert(attachmentList, self:getResourcePath(attachment));
	end
	return attachmentList;
end

return Weapon;