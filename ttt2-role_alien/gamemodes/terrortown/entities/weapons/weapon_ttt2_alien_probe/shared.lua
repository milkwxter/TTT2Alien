if SERVER then
	AddCSLuaFile()	
end

SWEP.HoldType               = "knife"

if CLIENT then
   SWEP.PrintName           = "alien_probe_name"
   SWEP.Slot                = 8
   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 70
   SWEP.DrawCrosshair       = false
	
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Probe enough players to win."
   };

   SWEP.Icon                = "vgui/ttt/icon_alien_probe"
   SWEP.IconLetter          = "j"

   function SWEP:Initialize()
		self:AddTTT2HUDHelp("Probe players & bodies to win. This also heals players.")
	end
end

SWEP.Base                   = "weapon_tttbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/c_aliendisintegrator.mdl"
SWEP.WorldModel             = "models/weapons/w_aliendisintegrator.mdl"

SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 2
SWEP.Primary.Ammo           = "none"
SWEP.Primary.Recoil			= 5

SWEP.Kind                   = WEAPON_CLASS
SWEP.AllowDrop              = false -- Is the player able to drop the swep

SWEP.IsSilent               = true

-- Pull out faster than standard guns
SWEP.DeploySpeed            = 2

--Removes the Probe on death or drop
function SWEP:OnDrop()
	self:Remove()
end

-- Override original primary attack
function SWEP:PrimaryAttack()
   	self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   	if not IsValid(self:GetOwner()) then return end

   	self:GetOwner():LagCompensation(true)

   	local spos = self:GetOwner():GetShootPos()
   	local sdest = spos + (self:GetOwner():GetAimVector() * 70)

   	local kmins = Vector(1,1,1) * -10
   	local kmaxs = Vector(1,1,1) * 10

   	local tr = util.TraceHull({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL, mins=kmins, maxs=kmaxs})

   	-- Hull might hit environment stuff that line does not hit
   	if not IsValid(tr.Entity) then
   		tr = util.TraceLine({start=spos, endpos=sdest, filter=self:GetOwner(), mask=MASK_SHOT_HULL})
   	end

   	local hitEnt = tr.Entity

   	-- effects
	if IsValid(hitEnt) then
		local edata = EffectData()
		edata:SetStart(spos)
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.Normal)
		edata:SetEntity(hitEnt)
		
		-- special alien effects
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		EmitSound( "npc/strider/striderx_pain2.wav", self:GetOwner():GetPos() )
		util.Effect("VortDispel", edata)
		if (IsValid(owner) and not owner:IsNPC() and owner.ViewPunch) then
			owner:ViewPunch(Angle(math.Rand(-0.2, -0.1) * self.Primary.Recoil, math.Rand(-0.1, 0.1) * self.Primary.Recoil, 0))
		end
		local recoil = self.Primary.Recoil
		if ((game.SinglePlayer() and SERVER) or ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then
			local eyeang = self:GetOwner():EyeAngles()
			eyeang.pitch = eyeang.pitch - recoil
			self:GetOwner():SetEyeAngles( eyeang )
		end

		-- if the entity he hit was a ragdoll
		if hitEnt:GetClass() == "prop_ragdoll" then
			-- get player of the corpse
			local corpsePlayer = CORPSE.GetPlayer(hitEnt)
		   	if not IsValid(corpsePlayer) then return end

			-- runs hook that will attempt to increase probed players by 1
			hook.Run("EVENT_ALIEN_PROBE", corpsePlayer)
		end
		--if the entity he hit was a player
		if hitEnt:IsPlayer() then
			-- heal the target alien style
			local toHeal = GetConVar("ttt2_alien_probe_healing"):GetInt()
			if hitEnt:Health() + toHeal > hitEnt:GetMaxHealth() then
				hitEnt:SetHealth(hitEnt:GetMaxHealth())
			else
				hitEnt:SetHealth(hitEnt:Health() + toHeal)
			end
			
			-- runs hook that will attempt to increase probed players by 1
			hook.Run("EVENT_ALIEN_PROBE", hitEnt)
		end
	end

   	if SERVER then
		self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   	end
   
   self:GetOwner():LagCompensation(false)
end