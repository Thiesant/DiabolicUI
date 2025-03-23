local ADDON, Engine = ...

	-- ActionButton Sizes 
local BUTTON_SIZE_VEHICLE = 64 -- button size with a vehicle UI
local BUTTON_SIZE_SINGLE = 50 -- button size with a single action bar
local BUTTON_SIZE_DOUBLE = 44 -- button size with two action bars
local BUTTON_SIZE_TRIPLE = 36 -- button size with three action bars

Engine:SetConstant("BUTTON_SIZE_VEHICLE", BUTTON_SIZE_VEHICLE)
Engine:SetConstant("BUTTON_SIZE_SINGLE", BUTTON_SIZE_SINGLE)
Engine:SetConstant("BUTTON_SIZE_DOUBLE", BUTTON_SIZE_DOUBLE)
Engine:SetConstant("BUTTON_SIZE_TRIPLE", BUTTON_SIZE_TRIPLE)

local NUM_ACTIONBAR_SLOTS = Engine:GetConstant("NUM_ACTIONBAR_SLOTS") -- number of buttons on a standard bar
local NUM_PET_SLOTS = Engine:GetConstant("NUM_PET_SLOTS") -- number of pet buttons
local NUM_POSSESS_SLOTS = Engine:GetConstant("NUM_POSSESS_SLOTS") -- number of possess buttons
local NUM_STANCE_SLOTS = Engine:GetConstant("NUM_STANCE_SLOTS") -- number of stance buttons
local NUM_VEHICLE_SLOTS = Engine:GetConstant("NUM_VEHICLE_SLOTS") -- number of vehicle buttons

-- path to our media folder
local path = ([[Interface\AddOns\%s\media\]]):format(ADDON)

-- padding between bars and buttons
local padding, padding_small, padding_pet = 4, 2, 2
local bar_inset, sidebar_inset = 10, 20 
local artwork_offscreen = 20 -- how many pixels to move the bottom artwork below the screen edge

-- size of the xpbar
local xpoffset_before, xpsize, xpoffset_after = 2, 7, 2

-- skull stuff
local skulloffset = 78

-- offset for the petbar
--local petoffset = 46 + 38 + 4 + 38 + 6
--local petskulloffset = petoffset + BUTTON_SIZE_TRIPLE - 3
local petoffset = 10
local petskulloffset = petoffset + BUTTON_SIZE_TRIPLE - 3

-- artwork offsets (angel + demon)
local angel_offset = 128 + 64
local demon_offset = 128 + 64 + 4 -- turns out I didn't align them perfectly in the graphic file


Engine:NewStaticConfig("ActionBars", {
	structure = {
		controllers = {

			-- holder for bottom bars
			-- intended for other modules to position by as well
			main = {
				padding = padding,
				position = {
					point = "BOTTOM",
					anchor = "UICenter", 
					anchor_point = "BOTTOM",
					xoffset = 0,
					yoffset = bar_inset
				},
				size = {
					["1"] = { BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_SINGLE },
					["2"] = { BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_DOUBLE*2 + padding },
					["3"] = { BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_TRIPLE*3 + padding*2 },
					["vehicle"] = { BUTTON_SIZE_VEHICLE*NUM_VEHICLE_SLOTS + padding*(NUM_VEHICLE_SLOTS-1), BUTTON_SIZE_VEHICLE }
				}
			},
			
			-- xp / rep bar holders
			xp = {
				position = { "TOP", 0, 10 + 6 },
				size = {
					["1"] = { 2 + BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1) + 2, 10 },
					["2"] = { 2 + BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1) + 2, 10 },
					["3"] = { 2 + BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1) + 2, 10 }
				}
			},

			-- holder for pet bar
			pet = {
				padding = padding_pet,
				position = {
					point = "BOTTOM",
					anchor = "Main", 
					anchor_point = "TOP",
					xoffset = 0,
					yoffset = petoffset 
				},
				size = { BUTTON_SIZE_TRIPLE*NUM_PET_SLOTS + padding_pet*(NUM_PET_SLOTS-1), BUTTON_SIZE_TRIPLE },
				size_vehicle = { BUTTON_SIZE_TRIPLE*NUM_PET_SLOTS + padding_pet*(NUM_PET_SLOTS-1), BUTTON_SIZE_TRIPLE }
			},

			-- holder for stance bar
			--stance = {
			--	padding = padding_pet,
			--	position = {
			--		point = "BOTTOMRIGHT",
			--		anchor = "Main", 
			--		anchor_point = "BOTTOMRIGHT",
			--		xoffset = 200,
			--		yoffset = 155
			--		--anchor_point = "TOP",
			--		--xoffset = 0,
			--		--yoffset = 91
			--	},
			--	size = { 38, 38 }
			--},
			
			-- holders for menu buttons
			mainmenu = {
				padding = 3,
				position = {
					point = "BOTTOMRIGHT",
					anchor = "UICenter", 
					anchor_point = "BOTTOMRIGHT",
					xoffset = -20,
					yoffset = 20 + 10
				},
				size = { 61*3 + 10*2, 55 }
			},
			chatmenu = {
				padding = 3,
				position = {
					point = "BOTTOMLEFT",
					anchor = "UICenter", 
					anchor_point = "BOTTOMLEFT",
					xoffset = 20,
					yoffset = 20 + 10
				},
				size = { 61*2 + 10*2, 55 }
			}
	
			
		},
		bars = {
			padding = padding,
			bar1 = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				padding = padding,
				bar_size = {
					["1"] = { BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_SINGLE },
					["2"] = { BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_DOUBLE },
					["3"] = { BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_TRIPLE }
				},
				buttonsize = {
					["1"] = BUTTON_SIZE_SINGLE,
					["2"] = BUTTON_SIZE_DOUBLE,
					["3"] = BUTTON_SIZE_TRIPLE
				}
			}, 
			bar2 = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				padding = padding,
				bar_size = {
					["1"] = { BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_SINGLE },
					["2"] = { BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_DOUBLE },
					["3"] = { BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_TRIPLE }
				},
				buttonsize = {
					["1"] = BUTTON_SIZE_SINGLE,
					["2"] = BUTTON_SIZE_DOUBLE,
					["3"] = BUTTON_SIZE_TRIPLE
				}
			},
			bar3 = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				padding = padding,
				bar_size = {
					["1"] = { BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_SINGLE },
					["2"] = { BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_DOUBLE },
					["3"] = { BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1), BUTTON_SIZE_TRIPLE }
				},
				buttonsize = {
					["1"] = BUTTON_SIZE_SINGLE,
					["2"] = BUTTON_SIZE_DOUBLE,
					["3"] = BUTTON_SIZE_TRIPLE
				}
			},
			bar4 = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				growth = "VERTICAL",
				hideGrid = true,
				padding = padding_small,
				position = { "BOTTOMLEFT", "Main", "BOTTOMRIGHT", 252, 0 },
				bar_size = {
					["0"] = { 0.0001, BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) },
					["1"] = { BUTTON_SIZE_TRIPLE*4 + padding_small*(4-1), BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) },
					["2"] = { BUTTON_SIZE_TRIPLE*4 + padding_small*(4-1), BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) }
				},
				buttonsize = {
					["1"] = BUTTON_SIZE_TRIPLE,
					["2"] = BUTTON_SIZE_TRIPLE
				}
			},
			bar5 = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				growth = "VERTICAL",
				hideGrid = true,
				padding = padding_small,
				position = { "BOTTOMRIGHT", "Main", "BOTTOMLEFT", -252, 0 },
				bar_size = {
					["0"] = { 0.0001, BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) },
					["1"] = { BUTTON_SIZE_TRIPLE*4 + padding_small*(4-1), BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) },
					["2"] = { BUTTON_SIZE_TRIPLE*4 + padding_small*(4-1), BUTTON_SIZE_TRIPLE*3 + padding_small*(3-1) }
				},
				buttonsize = {
					["1"] = BUTTON_SIZE_TRIPLE,
					["2"] = BUTTON_SIZE_TRIPLE
				}
			},
			vehicle = {
				flyout_direction = "UP",
				growthX = "RIGHT", 
				growthY = "UP",
				padding = padding,
				buttonsize = BUTTON_SIZE_VEHICLE,
				bar_size = { BUTTON_SIZE_VEHICLE*NUM_VEHICLE_SLOTS + padding*(NUM_VEHICLE_SLOTS-1), BUTTON_SIZE_VEHICLE }
			},
			stance = {
				position = { "BOTTOMRIGHT", "Main", "BOTTOMRIGHT", 200, 203 }, 
				growth = "UP", 
				padding = padding_small,
				buttonsize = BUTTON_SIZE_TRIPLE,
				bar_size = {
					[0] = { .0001, .0001 },
					[1] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE },
					[2] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-8) + padding_small*(NUM_STANCE_SLOTS-9) },
					[3] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-7) + padding_small*(NUM_STANCE_SLOTS-8) },
					[4] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-6) + padding_small*(NUM_STANCE_SLOTS-7) },
					[5] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-5) + padding_small*(NUM_STANCE_SLOTS-6) },
					[6] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-4) + padding_small*(NUM_STANCE_SLOTS-5) },
					[7] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-3) + padding_small*(NUM_STANCE_SLOTS-4) },
					[8] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-2) + padding_small*(NUM_STANCE_SLOTS-3) },
					[9] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-1) + padding_small*(NUM_STANCE_SLOTS-2) },
					[10] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE*NUM_STANCE_SLOTS + padding_small*(NUM_STANCE_SLOTS-1) }

					--[1] = { BUTTON_SIZE_TRIPLE, BUTTON_SIZE_TRIPLE },
					--[2] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-8) + padding_small*(NUM_STANCE_SLOTS-9), BUTTON_SIZE_TRIPLE },
					--[3] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-7) + padding_small*(NUM_STANCE_SLOTS-8), BUTTON_SIZE_TRIPLE },
					--[4] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-6) + padding_small*(NUM_STANCE_SLOTS-7), BUTTON_SIZE_TRIPLE },
					--[5] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-5) + padding_small*(NUM_STANCE_SLOTS-6), BUTTON_SIZE_TRIPLE },
					--[6] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-4) + padding_small*(NUM_STANCE_SLOTS-5), BUTTON_SIZE_TRIPLE },
					--[7] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-3) + padding_small*(NUM_STANCE_SLOTS-4), BUTTON_SIZE_TRIPLE },
					--[8] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-2) + padding_small*(NUM_STANCE_SLOTS-3), BUTTON_SIZE_TRIPLE },
					--[9] = { BUTTON_SIZE_TRIPLE*(NUM_STANCE_SLOTS-1) + padding_small*(NUM_STANCE_SLOTS-2), BUTTON_SIZE_TRIPLE },
					--[10] = { BUTTON_SIZE_TRIPLE*NUM_STANCE_SLOTS + padding_small*(NUM_STANCE_SLOTS-1), BUTTON_SIZE_TRIPLE }
				}
			},
			pet = {
				--position = { "BOTTOM", 0, xpoffset_before + xpsize + xpoffset_after },
				position = { "BOTTOM", 0, 0 }, -- where the bar is anchored to its controller
				positionXP = { "BOTTOM", 0, xpoffset_before + xpsize + xpoffset_after },
				flyout_direction = "UP",
				growth = "RIGHT",
				padding = padding_pet,
				hideGrid = false,
				buttonsize = BUTTON_SIZE_TRIPLE,
				bar_size = { BUTTON_SIZE_TRIPLE*NUM_PET_SLOTS + padding_pet*(NUM_PET_SLOTS-1), BUTTON_SIZE_TRIPLE }
			},

			floaters = {
				position = { "BOTTOMRIGHT", 200, 155 },
				size = { 38*2 + 6, 38 } -- currently only 2 button positions in this one
			}

		}
	},
	visuals = {
		artwork = {
			pet = {
				disableAutomation = true, 
				size = { 512, 86 },
				position = { "TOP", 0, 46 },
				texcoords = { 0/512, 512/512, 0/128, 85/128 },
				texture = path .. [[textures\DiabolicUI_PetBar_512x128_ArtWork.tga]]
			},

			backdrop = {
				callback = "texture",
				layer = "BACKGROUND",
				size = { 1024, 256 }, 
				position = { "BOTTOM", 0, -artwork_offscreen },
				texture = {
					["1"] = path .. [[textures\DiabolicUI_ActionBarArt1Bar.tga]],
					["1xp"] = path .. [[textures\DiabolicUI_ActionBarArt1BarXP.tga]],
					["2"] = path .. [[textures\DiabolicUI_ActionBarArt2Bars.tga]],
					["2xp"] = path .. [[textures\DiabolicUI_ActionBarArt2BarsXP.tga]],
					["3"] = path .. [[textures\DiabolicUI_ActionBarArt3Bars.tga]],
					["3xp"] = path .. [[textures\DiabolicUI_ActionBarArt3BarsXP.tga]],
					["vehicle"] = path .. [[textures\DiabolicUI_ActionBarArtVehicle.tga]],
					["vehiclexp"] = path .. [[textures\DiabolicUI_Artwork_Skull.tga]]
				}
			},
			--
			angel = {
				callback = "position",
				globalName = "DiabolicUIAngelTexture",
				layer = "OVERLAY",
				size = { 256, 256 },
				texture = path .. [[textures\DiabolicUI_Artwork_Angel.tga]],
				position = {
					["1"] = { "BOTTOM", ( (BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + demon_offset ), -artwork_offscreen },
					["2"] = { "BOTTOM", ( (BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + demon_offset ), -artwork_offscreen },
					["3"] = { "BOTTOM", ( (BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + demon_offset ), -artwork_offscreen },
					["vehicle"] = { "BOTTOM", ( (BUTTON_SIZE_VEHICLE*NUM_VEHICLE_SLOTS + padding*(NUM_VEHICLE_SLOTS-1))/2 + demon_offset ), -artwork_offscreen }
				}
			},
			demon = {
				callback = "position",
				globalName = "DiabolicUIDemonTexture",
				layer = "OVERLAY",
				size = { 256, 256 },
				texture = path .. [[textures\DiabolicUI_Artwork_Demon.tga]],
				position = {
					["1"] = { "BOTTOM", -( (BUTTON_SIZE_SINGLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + angel_offset ), -artwork_offscreen },
					["2"] = { "BOTTOM", -( (BUTTON_SIZE_DOUBLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + angel_offset ), -artwork_offscreen },
					["3"] = { "BOTTOM", -( (BUTTON_SIZE_TRIPLE*NUM_ACTIONBAR_SLOTS + padding*(NUM_ACTIONBAR_SLOTS-1))/2 + angel_offset ), -artwork_offscreen },
					["vehicle"] = { "BOTTOM", -( (BUTTON_SIZE_VEHICLE*NUM_VEHICLE_SLOTS + padding*(NUM_VEHICLE_SLOTS-1))/2 + angel_offset ), -artwork_offscreen }
				}
			},
			skull = {
				callback = "position",
				globalName = "DiabolicUISkullTexture",
				layer = "OVERLAY",
				size = { 512, 128 },
				texture = path .. [[textures\DiabolicUI_Artwork_Skull.tga]],
				position = {
					["1"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_SINGLE + bar_inset - skulloffset },
					["1pet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_SINGLE + bar_inset - skulloffset + petskulloffset },
					["1xp"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_SINGLE + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset },
					["1xppet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_SINGLE + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset + petskulloffset },
					["2"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_DOUBLE*2 + padding + bar_inset - skulloffset },
					["2pet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_DOUBLE*2 + padding + bar_inset - skulloffset + petskulloffset },
					["2xp"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_DOUBLE*2 + padding + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset },
					["2xppet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_DOUBLE*2 + padding + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset + petskulloffset },
					["3"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_TRIPLE*3 + padding*2 + bar_inset - skulloffset },
					["3pet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_TRIPLE*3 + padding*2 + bar_inset - skulloffset + petskulloffset },
					["3xp"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_TRIPLE*3 + padding*2 + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset },
					["3xppet"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_TRIPLE*3 + padding*2 + bar_inset + xpoffset_before + xpsize + xpoffset_after - skulloffset + petskulloffset },
					["vehicle"] = { "BOTTOM", 0, bar_inset + BUTTON_SIZE_VEHICLE + bar_inset - skulloffset }
				}
			}
		},
		buttons = {
			-- three main bars, or any side-, pet- or stance bar
			[36] = { -- the index match the button size
				icon = {
					size = { 28, 28 },
					points = { { "TOPLEFT", 4, -4 } }, 
					texcoords = { 5/64, 59/64, 5/64, 59/64 }
				},
				-- scaffold (bottom) frame
				backdrop = { 
					size = { 36, 36 },
					points = { { "TOPLEFT", 0, 0 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = nil
				},
				slot = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_BackdropWeapon.tga]]
				},
				
				-- cooldown frame
				cooldown = {
					size = { 28, 28 },
					points = { { "TOPLEFT", 4, -4 } }, 
					alpha = .5,
					color = { 0, 0, 0 },
					texture = nil
				},
				cooldown_numbers = {
					normalFont = DiabolicFont_SansBold16,
					points = { { "CENTER", 0, 0 } }
				},
				
					-- border frame
				border_empty = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_Border.tga]]
				},
				border_empty_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_BorderHighlight.tga]]
				},
				border_normal = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_Border.tga]]
				},
				border_normal_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_BorderHighlight.tga]]
				},
				border_checked = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_Checked.tga]]
				},
				border_checked_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -14, 14 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_36x36_CheckedHighlight.tga]]
				},
				
				-- border frame, texts
				nametext = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOM", 0, 0 }, { "LEFT", 0, 0 }, { "RIGHT", 0, 0 } }
				},
				keybind = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "TOPRIGHT", -5, -4 } }
				},
				stacksize = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOMRIGHT", -5, 4 } }
				}
			},
			
			-- two main bars
			[44] = { 
				icon = {
					size = { 32, 32 },
					points = { { "TOPLEFT", 6, -6 } }, 
					texcoords = { 5/64, 59/64, 5/64, 59/64 }
				},
			
				-- scaffold (bottom) frame
				backdrop = { 
					size = { 44, 44 },
					points = { { "TOPLEFT", 0, 0 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = nil
				},
				slot = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_BackdropWeapon.tga]]
				},
				
				-- cooldown frame
				cooldown = {
					size = { 32, 32 },
					points = { { "TOPLEFT", 6, -6 } }, 
					alpha = .5,
					color = { 0, 0, 0 },
					texture = nil
				},
				cooldown_numbers = {
					normalFont = DiabolicFont_SansBold16,
					points = { { "CENTER", 0, 0 } }
				},
				
					-- border frame
				border_empty = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_Empty.tga]]
				},
				border_empty_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_EmptyHighlight.tga]]
				},
				border_normal = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_Border.tga]]
				},
				border_normal_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_BorderHighlight.tga]]
				},
				border_checked = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_Checked.tga]]
				},
				border_checked_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -10, 10 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_44x44_CheckedHighlight.tga]]
				},
				
				-- border frame, texts
				nametext = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOM", 0, 0 }, { "LEFT", 0, 0 }, { "RIGHT", 0, 0 } }
				},
				keybind = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "TOPRIGHT", -7, -6 } }
				},
				stacksize = {
					normalFont = DiabolicFont_SansBold12,
					points = { { "BOTTOMRIGHT", -7, 6 } }
				}
			},
			
			-- single main bar or custom bar
			[50] = { 
				icon = {
					size = { 40, 40 },
					points = { { "TOPLEFT", 5, -5 } }, 
					texcoords = { 5/64, 59/64, 5/64, 59/64 }
				},
				-- scaffold (bottom) frame
				backdrop = { 
					size = { 50, 50 },
					points = { { "TOPLEFT", 0, 0 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = nil
				},
				slot = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_BackdropWeapon.tga]]
				},
				
				-- cooldown frame
				cooldown = {
					size = { 40, 40 },
					points = { { "TOPLEFT", 5, -5 } }, 
					alpha = .5,
					color = { 0, 0, 0 },
					texture = nil
				},
				cooldown_numbers = {
					normalFont = DiabolicFont_SansBold16,
					points = { { "CENTER", 0, 0 } }
				},
				
					-- border frame
				border_empty = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_Border.tga]]
				},
				border_empty_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_BorderHighlight.tga]]
				},
				border_normal = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_Border.tga]]
				},
				border_normal_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_BorderHighlight.tga]]
				},
				border_checked = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_Checked.tga]]
				},
				border_checked_highlight = {
					size = { 64, 64 },
					points = { { "TOPLEFT", -7, 7 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_50x50_CheckedHighlight.tga]]
				},
				
				-- border frame, texts
				nametext = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOM", 0, 0 }, { "LEFT", 0, 0 }, { "RIGHT", 0, 0 } }
				},
				keybind = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "TOPRIGHT", -7, -6 } }
				},
				stacksize = {
					normalFont = DiabolicFont_SansBold12,
					points = { { "BOTTOMRIGHT", -7, 6 } }
				}
			},
			
			-- vehicle bar, or extra actionbutton
			[64] = {
				icon = {
					size = { 52, 52 },
					points = { { "TOPLEFT", 6, -6 } }, 
					texcoords = { 5/64, 59/64, 5/64, 59/64 }
				},
				-- scaffold (bottom) frame
				backdrop = { 
					size = { 64, 64 },
					points = { { "TOPLEFT", 0, 0 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = nil
				},
				slot = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_BackdropWeapon.tga]]
				},
				
				-- cooldown frame
				cooldown = {
					size = { 52, 52 },
					points = { { "TOPLEFT", 6, -6 } }, 
					alpha = .5,
					color = { 0, 0, 0 },
					texture = nil
				},
				cooldown_numbers = {
					normalFont = DiabolicFont_SansBold16,
					points = { { "CENTER", 0, 0 } }
				},
				
				-- border frame
				border_empty = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_Border.tga]]
				},
				border_empty_highlight = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_BorderHighlight.tga]]
				},
				border_normal = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_Border.tga]]
				},
				border_normal_highlight = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_BorderHighlight.tga]]
				},
				border_checked = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_Checked.tga]]
				},
				border_checked_highlight = {
					size = { 128, 128 },
					points = { { "TOPLEFT", -32, 32 } }, 
					texcoords = { 0, 1, 0, 1 },
					alpha = 1,
					color = { 1, 1, 1 },
					texture = path .. [[textures\DiabolicUI_Button_64x64_CheckedHighlight.tga]]
				},
				
				-- border frame, texts
				nametext = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOM", 0, 0 }, { "LEFT", 0, 0 }, { "RIGHT", 0, 0 } }
				},
				keybind = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "TOPRIGHT", -7, -6 } }
				},
				stacksize = {
					normalFont = DiabolicFont_SansBold10,
					points = { { "BOTTOMRIGHT", -7, 6 } }
				}
			}
		},
		floaters = {
			style = {

			},
			-- Stance bar toggle button
			stance = {
				size = { 38, 38 },
				position = { "BOTTOMRIGHT", 0, 0 },
				icon = {
					texture = [[Interface\Icons\Spell_Nature_WispSplode]], 
					texcoords = { 5/64, 59/64, 5/64, 59/64 },
					size = { 36, 36 },
					position = { "CENTER", 0, 0 },
					position_pushed = { "CENTER", 0, -2 }
				},
				border = {
					size = { 64, 64 },
					position = { "CENTER", 0, 0 },
					textures = {
						normal = path .. [[textures\DiabolicUI_Button_37x37_Normal.tga]],
						highlight = path .. [[textures\DiabolicUI_Button_37x37_Highlight.tga]]
					}
				}
			},
			-- Vehicle Exit button, and Taxi cancel flight button
			-- *This one has slightly different sizing, since it has the icon embedded in the artwork.
			exit = {
				size = { 36, 36 },
				position = { "BOTTOMRIGHT", 0, 0 },
				texture_size = { 64, 64 },
				texture_position = { "CENTER", 0, 0 },
				textures = {
					normal = path .. [[textures\DiabolicUI_ExitButton_37x37_Normal.tga]],
					highlight = path .. [[textures\DiabolicUI_ExitButton_37x37_Highlight.tga]],
					pushed = path .. [[textures\DiabolicUI_ExitButton_37x37_Pushed.tga]],
					disabled = path .. [[textures\DiabolicUI_ExitButton_37x37_Disabled.tga]]
				}
			},
			extra = {
				size = { 38, 38 },
				position = { "BOTTOMRIGHT", 54, 0 },
				icon = {
					texcoords = { 5/64, 59/64, 5/64, 59/64 },
					size = { 38, 38 },
					position = { "CENTER", 0, 0 },
					position_pushed = { "CENTER", 0, -2 }
				},
				border = {
					size = { 64, 64 },
					position = { "CENTER", 0, 0 },
					textures = {
						normal = path .. [[textures\DiabolicUI_Button_37x37_Normal.tga]],
						highlight = path .. [[textures\DiabolicUI_Button_37x37_Highlight.tga]]
					}
				}
			},
			-- Zone abilities (WoD, Legion)
			zone = {
				size = { 38, 38 },
				position = { "BOTTOMRIGHT", 54, 0 },
				icon = {
					texcoords = { 5/64, 59/64, 5/64, 59/64 },
					size = { 38, 38 },
					position = { "CENTER", 0, 0 },
					position_pushed = { "CENTER", 0, -2 }
				},
				border = {
					size = { 64, 64 },
					position = { "CENTER", 0, 0 },
					textures = {
						normal = path .. [[textures\DiabolicUI_Button_37x37_Normal.tga]],
						highlight = path .. [[textures\DiabolicUI_Button_37x37_Highlight.tga]]
					}
				}
			}
		},
		menus = {
			icons = {
				size = { 40, 40 },
				position = { "CENTER", 0, 0 },
				alpha = .8,
				pushed = {
					alpha = 1,
					position = { "CENTER", 0, -4 }
				},
				texture = path .. [[textures\DiabolicUI_40x40_MenuIconGrid.tga]],
				texture_size = { 256, 256 },
				texcoords = {
					character = { 0, 39/255, 0, 39/255 },
					spellbook = { 40/255, 79/255, 0/255, 39/255 },
					talents = { 80/255, 119/255, 0/255, 39/255 },
					achievements = { 120/255, 159/255, 0/255, 39/255 },
					questlog = { 160/255, 199/255, 0/255, 39/255 },
					worldmap = { 200/255, 239/255, 0/255, 39/255 },

					guild = { 0/255, 39/255, 40/255, 79/255 },
					horde = { 40/255, 79/255, 40/255, 79/255 },
					alliance = { 80/255, 119/255, 40/255, 79/255 },
					group = { 120/255, 159/255, 40/255, 79/255 },
					raid = { 160/255, 199/255, 40/255, 79/255 },
					encounterjournal = { 200/255, 239/255, 40/255, 79/255 },

					store = { 0/255, 39/255, 80/255, 119/255 },
					mainmenu = { 40/255, 79/255, 80/255, 119/255 },
					bug = { 80/255, 119/255, 80/255, 119/255 },
					unlocked = { 120/255, 159/255, 80/255, 119/255 },
					locked = { 160/255, 199/255, 80/255, 119/255 },
					chat = { 200/255, 239/255, 80/255, 119/255 },

					mail = { 0/255, 39/255, 120/255, 159/255 },
					bag = { 40/255, 79/255, 120/255, 159/255 },
					mount = { 80/255, 119/255, 120/255, 159/255 },
					neutral = { 120/255, 239/255, 120/255, 159/255 },
					cog = { 160/255, 199/255, 120/255, 159/255 },
					cogs = { 200/255, 239/255, 120/255, 159/255 },
					
					bars = { 0/255, 39/255, 160/255, 199/255 },
					twobars = { 40/255, 79/255, 160/255, 199/255 },
					onebar = { 80/255, 1199/255, 160/255, 199/255 },
					empty = { 120/255, 159/255, 160/255, 199/255 },
					onesidebar = { 160/255, 199/255, 160/255, 199/255 },
					twosidebars = { 200/255, 39/255, 160/255, 199/255 }
				}
			},
			chat = {
				input = {
					button = {
						size = { 61, 55 }, 
						anchor = "TOPLEFT", -- where buttons are anchored
						growthX = "RIGHT", -- horizontal layout direction
						growthY = "DOWN", -- vertical layout direction
						justify = "RIGHT", -- which side the last row of buttons should be on
						padding = 3, spacing = 6, -- horizontal and vertical padding
						texture_size = { 128, 128 },
						texture_position = { "TOPLEFT", -34, 37 },
						textures = {
							normal = path .. [[textures\DiabolicUI_UIButton_61x55_Normal.tga]],
							pushed = path .. [[textures\DiabolicUI_UIButton_61x55_Pushed.tga]]
						}
					},
					people = {
						normalFont = DiabolicFont_SansBold10Gray,
						position = { "BOTTOMLEFT", 6, -20  } -- relative to the chatmenu's menubutton
					}
				},
				menu = {
					button = {
						size = { 61, 55 }, 
						anchor = "TOPLEFT", -- where buttons are anchored
						growthX = "RIGHT", -- horizontal layout direction
						growthY = "DOWN", -- vertical layout direction
						justify = "RIGHT", -- which side the last row of buttons should be on
						padding = 3, spacing = 6, -- horizontal and vertical padding
						texture_size = { 128, 128 },
						texture_position = { "TOPLEFT", -34, 37 },
						textures = {
							normal = path .. [[textures\DiabolicUI_UIButton_61x55_Normal.tga]],
							pushed = path .. [[textures\DiabolicUI_UIButton_61x55_Pushed.tga]]
						}
					},
					people = {
						normalFont = DiabolicFont_SansBold14Title,
						position = { "BOTTOMRIGHT", -12, 12  } -- relative to the socialmenu's menubutton
					}
				},
			},
			main = {
				-- Top level objects are menubuttons onscreen
				-- that opens windows with more buttons.
				micromenu = {
					-- without the backdrop
					position = { "BOTTOMRIGHT", 0, 55 + 10 }, -- relative to its parent menubutton
					insets = { 0, 0, 0, 0 }, -- insets from the frame edge to the content
					-- with a backdrop
					--position = { "BOTTOMRIGHT", -(0 -15), (55 + 3) -15 }, -- relative to its parent menubutton
					--insets = { 24 + 6, 24 + 6, 24 + 6, 24 + 6 }, -- insets from the frame edge to the content
					button = {
						size = { 61, 55 }, 
						anchor = "TOPLEFT", -- where buttons are anchored
						growthX = "RIGHT", -- horizontal layout direction
						growthY = "DOWN", -- vertical layout direction
						justify = "RIGHT", -- which side the last row of buttons should be on
						padding = 3, spacing = 6, -- horizontal and vertical padding
						texture_size = { 128, 128 },
						texture_position = { "TOPLEFT", -34, 37 },
						textures = {
							normal = path .. [[textures\DiabolicUI_UIButton_61x55_Normal.tga]],
							pushed = path .. [[textures\DiabolicUI_UIButton_61x55_Pushed.tga]]
						}
					},
					backdrop = nil,
					backdrop2 = {
						bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
						edgeFile = path .. [[textures\DiabolicUI_Tooltip_Border.tga]],
						edgeSize = 32,
						tile = false,
						tileSize = 0,
						insets = {
							left = 23,
							right = 23,
							top = 23,
							bottom = 23
						}
					},
					backdrop_color = { 0, 0, 0, .75 },
					backdrop_border_color = { 1, 1, 1, 1 },
					performance = {
						normalFont = DiabolicFont_SansBold10Gray,
						position = { "BOTTOMRIGHT", -6, -20  } -- relative to the micromenu's menubutton
					}
				},
				barmenu = {
					size = { 390, 620 },
					position = { "BOTTOMRIGHT", -(0 -15) + (61 + 3), (55 + 10) -15 }, -- relative to its parent menubutton
					insets = { 24 + 6, 24 + 6, 24 + 6, 24 + 6 }, -- insets from the frame edge to the content
					ui = {
						window = {
							padding = 5,
							insets = { 6, 6, 6, 6 }, -- left, right, top, bottom
							backdrop = {
								bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
								edgeFile = path .. [[textures\DiabolicUI_Tooltip_Border.tga]],
								edgeSize = 32,
								tile = false,
								tileSize = 0,
								insets = {
									left = 23,
									right = 23,
									top = 23,
									bottom = 23
								}
							},
							backdrop_color = { 0, 0, 0, .75 },
							backdrop_border_color = { 1, 1, 1, 1 },
							header = {
								insets = { 29, 29, 29, 29 },
								height = 40, 
								backdrop = {
									bgFile = path .. [[textures\DiabolicUI_Tooltip_Header_TitleBackground.tga]],
									edgeFile = path .. [[textures\DiabolicUI_Tooltip_Header.tga]],
									edgeSize = 32,
									insets = {
										left = 3,
										right = 3,
										top = 3,
										bottom = 3
									}
								},
								backdrop_color = { 0, 0, 0, .5 },
								backdrop_border_color = { 1, 1, 1, 1 },
								texture = {
									left = {
										texture = path .. [[textures\DiabolicUI_Tooltip_TitleDecoration.tga]],
										offset = -5,
										size = { 32, 64 },
										texcoord = { 0, 31/128, 0, 1 }
									},
									right = {
										texture = path .. [[textures\DiabolicUI_Tooltip_TitleDecoration.tga]],
										offset = 12,
										size = { 64, 64 },
										texcoord = { 32/128, 95/128, 0, 1 }
									},
									top = {
										texture = path .. [[textures\DiabolicUI_Tooltip_TitleDecoration.tga]],
										offset = 5,
										size = { 32, 64 },
										texcoord = { 96/128, 1, 0, 1 }
									}
								},
								title = {
									normalFont = DiabolicFont_HeaderRegular18Title,
									insets = { 30, 30, 0, 0 }
								}
							},
							body = {
								insets = { 29, 29, 29, 29 },
								backdrop = {
									bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
									edgeFile = path .. [[textures\DiabolicUI_Tooltip_Body.tga]],
									edgeSize = 32,
									insets = {
										left = 3,
										right = 3,
										top = 2,
										bottom = 2
									}
								},
								backdrop_color = { 0, 0, 0, 0 },
								backdrop_border_color = { 71/255 *3.5, 56/255 *3.5, 28/255 *3.5, 1 }
							},
							footer = {
								button_spacing = 29, -- horizontal space between buttons, if multiple
								insets = { 28, 28, 28, 28 }, -- left, right, top, bottom
								offset = 3, -- offset from the body before it
								backdrop = {
									bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
									edgeFile = path .. [[textures\DiabolicUI_Tooltip_Footer.tga]],
									edgeSize = 16,
									insets = {
										left = 3,
										right = 3,
										top = 3,
										bottom = 3
									}
								},
								backdrop_color = { 0, 0, 0, 0 },
								backdrop_border_color = { 1, 1, 1, 1 },
								message = {
									insets = { 30, 30, 20, 20 },
									normalFont = DiabolicFont_SansBold12White
								}
							}
						},
						menubutton = {
							size = { 300, 51 },
							normalFont= DiabolicFont_HeaderRegular18Title,
							highlightFont = DiabolicFont_HeaderRegular18Highlight,
							pushedFont = DiabolicFont_HeaderRegular18Highlight,
							texture_size = { 512, 128 },
							texture = {
								normal = path .. [[textures\DiabolicUI_UIButton_300x51_Normal.tga]],
								highlight = path .. [[textures\DiabolicUI_UIButton_300x51_Highlight.tga]],
								pushed = path .. [[textures\DiabolicUI_UIButton_300x51_Pushed.tga]]
							}
						}
						
					},
					button = {
						size = { 61, 55 }, 
						anchor = "TOPLEFT", -- where buttons are anchored
						growthX = "RIGHT", -- horizontal layout direction
						growthY = "DOWN", -- vertical layout direction
						padding = 3,
						texture_size = { 128, 128 },
						texture_position = { "TOPLEFT", -34, 37 },
						textures = {
							normal = path .. [[textures\DiabolicUI_UIButton_61x55_Normal.tga]],
							pushed = path .. [[textures\DiabolicUI_UIButton_61x55_Pushed.tga]]
						}
					},
					backdrop = {
						bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
						edgeFile = path .. [[textures\DiabolicUI_Tooltip_Border.tga]],
						edgeSize = 32,
						tile = false,
						tileSize = 0,
						insets = {
							left = 23,
							right = 23,
							top = 23,
							bottom = 23
						}
					},
					backdrop_color = { 0, 0, 0, .95 },
					backdrop_border_color = { 1, 1, 1, 1 },
					
				},
				bagmenu = {
					size = Engine:IsBuild("Cata") and { 158 + ( 24 * 2) + 2+2 , 30 + ( 24*2 ) + 2+3 }
						or Engine:IsBuild("WotLK") and { 198 + ( 24 * 2) + 2+2 , 37 + ( 24*2 ) + 3+3 },
					--position = { "BOTTOMRIGHT", -(0 -15) + (61 + 3)*2, (55 + 10) -15 }, -- relative to its parent menubutton
					position = { "TOPRIGHT", -50 , 15 }, -- relative to its parent menubutton
					insets = Engine:IsBuild("Cata") and { 24 + 2, 24 + 2, 24 + 2, 24 + 3 }
						or Engine:IsBuild("WotLK") and { 24 + 2, 24 + 2, 24 + 3, 24 + 3 }, -- insets from the frame edge to the content
					bag_offset = 37 + 6*2 + 10, -- vertical offset of the bag frame when the bag bar is visible
					button = {
						size = { 61, 55 }, 
						anchor = "TOPLEFT", -- where buttons are anchored
						growthX = "RIGHT", -- horizontal layout direction
						growthY = "DOWN", -- vertical layout direction
						padding = 3,
						texture_size = { 128, 128 },
						texture_position = { "TOPLEFT", -34, 37 },
						textures = {
							normal = path .. [[textures\DiabolicUI_UIButton_61x55_Normal.tga]],
							pushed = path .. [[textures\DiabolicUI_UIButton_61x55_Pushed.tga]]
						}
					},
					backdrop = {
						bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
						edgeFile = path .. [[textures\DiabolicUI_Tooltip_Border.tga]],
						edgeSize = 32,
						tile = false,
						tileSize = 0,
						insets = {
							left = 23,
							right = 23,
							top = 23,
							bottom = 23
						}
					},
					backdrop_color = { 0, 0, 0, .75 },
					backdrop_border_color = { 1, 1, 1, 1 }
				}
			}

		},
		xp = {
			normalFont = DiabolicFont_SansBold12White,
			bar = {
				alpha = 1,
				texture = path .. [[statusbars\DiabolicUI_StatusBar_512x64_Dark_Warcraft.tga]],
				spark = {
					size = { 16, 10 },
					texture = path .. [[statusbars\DiabolicUI_StatusBar_16x16_Spark_Warcraft.tga]]
				}
			},
			rested = {
				alpha = 1,
				texture = path .. [[statusbars\DiabolicUI_StatusBar_512x64_Dark_Warcraft.tga]],
				spark = {
					size = { 16, 10 },
					texture = path .. [[statusbars\DiabolicUI_StatusBar_16x16_Spark_Warcraft.tga]]
				}
			},
			backdrop = {
				texture_size = { 1024, 32 },
				texture_position = { "CENTER", 0, 0 },
				textures = { 
					["1"] = path .. [[textures\DiabolicUI_XPBackdrop1Bar.tga]],
					["2"] = path .. [[textures\DiabolicUI_XPBackdrop2Bars.tga]],
					["3"] = path .. [[textures\DiabolicUI_XPBackdrop3Bars.tga]]
				}
			}
		}
	}
})
