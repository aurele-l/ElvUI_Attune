local E, L, V, P, G = unpack(ElvUI);

Attune = {}
local unpack = unpack

function Attune:AddAtuneIcon(slot)
	if not slot.AttuneTextureBorder then
		local AttuneTextureBorder = slot:CreateTexture(nil, "ARTWORK")
		AttuneTextureBorder:SetTexture(E.Media.Textures.AttuneIconWhite)
		AttuneTextureBorder:SetVertexColor(0, 0, 0)
		AttuneTextureBorder:Hide()
		slot.AttuneTextureBorder = AttuneTextureBorder
	end

	if not slot.AttuneTexture then
		local AttuneTexture = slot:CreateTexture(nil, "OVERLAY")
		AttuneTexture:SetTexture(E.Media.Textures.AttuneIconWhite)
		AttuneTexture:Hide()
		slot.AttuneTexture = AttuneTexture
	end
end

function Attune:ToggleAttuneIcon(slot, itemId)
	Attune:UpdateItemLevelText(slot, itemId)
	Attune:AddAtuneIcon(slot)
	slot.AttuneTexture:Hide()
	slot.AttuneTextureBorder:Hide()
	if not E.db.bags.attuneProgress or itemId == 0 then
		return
	end
	if  Attune:CheckItemValid(itemId) == 0 then
		return
	end

	local margin = 2
	local borderWidth = 1
	local maxHeight = slot:GetHeight() - (margin*2 + borderWidth*2)
	local minHeight = maxHeight * 0.2
	local width = 8 - borderWidth * 2

	slot.AttuneTextureBorder:SetPoint("BOTTOMLEFT", margin, margin)
	slot.AttuneTextureBorder:SetWidth(width + borderWidth*2)
	slot.AttuneTexture:SetPoint("BOTTOMLEFT", margin + borderWidth, margin + borderWidth)
	slot.AttuneTexture:SetWidth(width)

	if Attune:CheckItemValid(itemId) == -2 then
		slot.AttuneTextureBorder:SetHeight(minHeight + borderWidth*2)
		slot.AttuneTexture:SetHeight(minHeight)
		slot.AttuneTexture:SetVertexColor(0.74, 0.02, 0.02)
		slot.AttuneTextureBorder:Show()
		slot.AttuneTexture:Show()
	elseif Attune:CheckItemValid(itemId) == 1 then
		local progress = GetItemAttuneProgress(itemId)
		if progress < 100 then
			local height = math.max(maxHeight * (progress/100), minHeight)
			slot.AttuneTextureBorder:SetHeight(height + borderWidth*2)
			slot.AttuneTexture:SetHeight(height)
			slot.AttuneTexture:SetVertexColor(0.96, 0.63, 0.02)
		else
			slot.AttuneTextureBorder:SetHeight(maxHeight + borderWidth*2)
			slot.AttuneTexture:SetHeight(maxHeight)
			if not E.db.bags.alternateProgressAttuneColor then
				slot.AttuneTexture:SetVertexColor(0, 0.64, 0.05)
			else
				slot.AttuneTexture:SetVertexColor(0.39, 0.56, 1)
			end
		end
		slot.AttuneTextureBorder:Show()
		slot.AttuneTexture:Show()
	end
end

function Attune:CheckItemValid(itemId)
	if type(itemId) ~= "number" then return 0 end
	if not CanAttuneItemHelper then return 0 end
	return CanAttuneItemHelper(itemId)
end

function Attune:UpdateItemLevelText(slot, itemId)
	if not slot.itemLevel then
		slot.itemLevel = slot:CreateFontString(nil, "OVERLAY")
		slot.itemLevel:Point("BOTTOMRIGHT", -1, 3)
		slot.itemLevel:FontTemplate(E.Libs.LSM:Fetch("font", E.db.bags.itemLevelFont), E.db.bags.itemLevelFontSize,
			E.db.bags.itemLevelFontOutline)
	end
	slot.itemLevel:SetText("")

	if itemId and itemId ~= 0 then
		local _, _, itemRarity, iLvl, _, _, _, _, itemEquipLoc, _, _ = GetItemInfo(itemId)
		if iLvl and E.db.bags.itemLevel and (itemEquipLoc ~= nil and itemEquipLoc ~= "" and itemEquipLoc ~= "INVTYPE_AMMO" and itemEquipLoc ~= "INVTYPE_BAG" and itemEquipLoc ~= "INVTYPE_QUIVER" and itemEquipLoc ~= "INVTYPE_TABARD") and (itemRarity and itemRarity > 1) and iLvl >= E.db.bags.itemLevelThreshold then
			slot.itemLevel:SetText(iLvl)
			if E.db.bags.itemLevelCustomColorEnable then
				slot.itemLevel:SetTextColor(E.db.bags.itemLevelCustomColor.r, E.db.bags.itemLevelCustomColor.g, E.db.bags.itemLevelCustomColor
					.b)
			else
				slot.itemLevel:SetTextColor(GetItemQualityColor(itemRarity))
			end
		end
	end
end