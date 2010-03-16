local Bagrealis, addon, ns = Bagrealis, ...

local LFX = LibStub("LibFx-1.1")

local Anims = {}
Bagrealis.Anims = Anims

function Anims.Move(aFrame, bFrame, xOffset, yOffset)
	local aX, aY, aEff = aFrame:GetLeft(), aFrame:GetTop(), aFrame:GetEffectiveScale()
	aX, aY = aX*aEff, aY*aEff

	local bX, bY, bEff = bFrame:GetLeft(), bFrame:GetTop(), bFrame:GetEffectiveScale()
	local bEff = aFrame:GetEffectiveScale()
	bX, bY = bX*bEff, bY*bEff

	local dX, dY = (bX-aX)/aEff, (bY-aY)/aEff

	aFrame:ClearAllPoints()
	aFrame:SetPoint("TOPLEFT", bFrame, "TOPLEFT", -dX, -dY)
	LFX.New{
		frame = aFrame,
		anim = "Translate",
		ramp = "Smooth",
		xOffset = dX+xOffset,
		yOffset = dY+yOffset,
		duration = 0.3,
	}()
end

function Anims.Show(frame)
	frame:SetAlpha(0)
	LFX.New{
		frame = frame,
		anim = "Alpha",
		finish = 1,
		duration = 0.3,
	}()
end