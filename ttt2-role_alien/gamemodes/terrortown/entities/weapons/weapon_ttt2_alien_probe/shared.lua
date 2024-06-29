if SERVER then
	AddCSLuaFile()	
end

SWEP.HoldType               = "knife"

if CLIENT then
   SWEP.PrintName           = "Alien Probe"
   SWEP.Slot                = 8
   SWEP.ViewModelFlip       = false
   SWEP.ViewModelFOV        = 90
   SWEP.DrawCrosshair       = false
	
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Probe enough players to win."
   };

   SWEP.Icon                = "vgui/ttt/icon_alien_probe"
   SWEP.IconLetter          = "j"
end

SWEP.Base                   = "weapon_tttbase"

SWEP.UseHands               = true
SWEP.ViewModel              = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel             = "models/weapons/w_knife_t.mdl"

SWEP.Primary.Damage         = 0
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Delay          = 2
SWEP.Primary.Ammo           = "none"

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
		self:SendWeaponAnim( ACT_VM_MISSCENTER )

		local edata = EffectData()
		edata:SetStart(spos)
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.Normal)
		edata:SetEntity(hitEnt)
		
		-- make a special sound
		EmitSound( "npc/strider/striderx_pain2.wav", self:GetOwner():GetPos() )

		--if the entity he hit was a ragdoll
		if hitEnt:GetClass() == "prop_ragdoll" then
			-- if he hits a body spawn a cool effect
			util.Effect("VortDispel", edata)
			-- warn player it does nothing to ragdolls
			if SERVER then
				local owner = self:GetOwner()
				LANG.Msg(owner, "You cannot probe ragdolls!", nil, MSG_MSTACK_WARN)
			end
		end
		--if the entity he hit was a player
		if hitEnt:IsPlayer() then
			-- if he hits a player spawn a cool effect
			util.Effect("VortDispel", edata)
			
			-- heal the target alien style
			if hitEnt:Health() + 25 > hitEnt:GetMaxHealth() then
				hitEnt:SetHealth(hitEnt:GetMaxHealth())
			else
				hitEnt:SetHealth(hitEnt:Health() + 25)
			end
			
			--runs hook that will increase bodies by one when the vulture consumes one
			--hook.Run("EVENT_VULT_CONSUME")
		end
	end

   if SERVER then
      self:GetOwner():SetAnimation( PLAYER_ATTACK1 )
   end
   
   self:GetOwner():LagCompensation(false)
end
