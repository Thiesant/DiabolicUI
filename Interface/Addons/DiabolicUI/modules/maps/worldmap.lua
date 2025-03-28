local _, Engine = ...
local Module = Engine:NewModule("Worldmap")
local L = Engine:GetLocale()
local C = Engine:GetDB("Data: Colors")

-- Lua API
local _G = _G
local math_ceil = math.ceil
local setmetatable = setmetatable
local string_format = string.format 
local string_match = string.match
local string_split = string.split

-- WoW API
local CreateFrame = _G.CreateFrame
local GetAchievementLink = _G.GetAchievementLink
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID
local hooksecurefunc = _G.hooksecurefunc
local RefreshWorldMap = _G.RefreshWorldMap
local SetMapByID = _G.SetMapByID

-- WoW Frames & Objects
local GameTooltip = _G.GameTooltip
local QuestMapFrame = _G.QuestMapFrame
local WorldMapDetailFrame = _G.WorldMapDetailFrame

-- WoW Client Constants
local ENGINE_BFA = Engine:IsBuild("BfA")
local ENGINE_LEGION = Engine:IsBuild("Legion")
local ENGINE_LEGION_720 = Engine:IsBuild("7.2.0")

-- let's just consider this not available in BfA for now
if ENGINE_BFA then 
	return
end

-- Add wowhead link by Goldpaw "Lars" Norberg
local subDomain = (setmetatable({
    ruRU = "ru",
    frFR = "fr", deDE = "de",
    esES = "es", esMX = "es",
    ptBR = "pt", ptPT = "pt", itIT = "it",
    koKR = "ko", zhTW = "cn", zhCN = "cn"
}, { __index = function() return "www" end }))[GetLocale()]

local wowheadLoc = subDomain..".wowhead.com"

----------------------------------------------------------------------------------------
--	Fog of War on World Map (module from LeatrixPlus by Leatrix)
----------------------------------------------------------------------------------------
local zones = {
	-- Eastern Kingdoms
	["Arathi"] = {"CirecleofOuterBinding:215:188:332:273", "CircleofWestBinding:220:287:85:24", "NorthfoldManor:227:268:132:105", "Bouldergor:249:278:171:123", "StromgardeKeep:284:306:21:269", "FaldirsCove:273:268:77:400", "CircleofInnerBinding:228:227:201:312", "ThandolSpan:237:252:261:416", "BoulderfistHall:252:258:327:367", "RefugePoint:196:270:293:145", "WitherbarkVillage:260:220:476:359", "GoShekFarm:306:248:430:249", "DabyriesFarmstead:210:227:404:144", "CircleofEastBinding:183:238:506:126", "Hammerfall:270:271:581:118", "GalensFall:212:305:0:144"},
	["Badlands"] = {"AgmondsEnd:342:353:230:315", "AngorFortress:285:223:230:68", "ApocryphansRest:252:353:0:66", "CampBoff:274:448:407:220", "CampCagg:339:347:0:281", "CampKosh:236:260:504:19", "DeathwingScar:328:313:175:178", "HammertoesDigsite:209:196:411:116", "LethlorRavine:469:613:533:55", "TheDustbowl:214:285:144:99", "Uldaman:266:210:336:0",},
	["BlastedLands"] = {"AltarofStorms:238:195:225:110", "DreadmaulHold:272:206:258:0", "DreadmaulPost:235:188:327:182", "NethergardeKeep:295:205:530:6", "NethergardeSupplyCamps:195:199:436:0", "RiseoftheDefiler:168:170:375:102", "SerpentsCoil:218:183:459:97", "Shattershore:240:270:578:91", "SunveilExcursion:233:266:386:374", "Surwich:199:191:333:474", "TheDarkPortal:370:298:368:179", "TheRedReaches:268:354:533:268", "TheTaintedForest:348:357:132:311", "TheTaintedScar:308:226:144:175",},
	["BlastedLands_terrain1"] = {"AltarofStorms:238:195:225:110", "DreadmaulHold:272:206:258:0", "DreadmaulPost:235:188:327:182", "NethergardeKeep:295:205:530:6", "NethergardeSupplyCamps:195:199:436:0", "RiseoftheDefiler:168:170:375:102", "SerpentsCoil:218:183:459:97", "Shattershore:240:270:578:91", "SunveilExcursion:233:266:386:374", "Surwich:199:191:333:474", "TheDarkPortal:370:298:368:179", "TheRedReaches:268:354:533:268", "TheTaintedForest:348:357:132:311", "TheTaintedScar:308:226:144:175",},
	["BurningSteppes"] = {"AltarofStorms:182:360:0:0", "BlackrockMountain:281:388:79:0", "BlackrockPass:298:410:419:258", "BlackrockStronghold:320:385:235:0", "Dracodar:362:431:0:237", "DreadmaulRock:274:263:568:151", "MorgansVigil:383:413:615:255", "PillarofAsh:274:413:253:255", "RuinsofThaurissan:324:354:421:0", "TerrorWingPath:350:341:646:7",},
	["Darkshore"] = {"AmethAran:326:145:294:330", "EyeoftheVortex:330:192:300:239", "Lordanel:277:281:391:54", "Nazjvel:244:201:207:467", "RuinsofAuberdine:203:194:280:182", "RuinsofMathystra:200:263:517:28", "ShatterspearVale:250:241:596:16", "ShatterspearWarcamp:245:147:565:0", "TheMastersGlaive:303:185:277:483", "WildbendRiver:314:193:280:378", "WitheringThicket:328:250:305:118",},
	["DeadwindPass"] = {"DeadmansCrossing:617:522:83:0", "Karazhan:513:358:92:310", "TheVice:350:449:433:208",},
	["DunMorogh"] = {"AmberstillRanch:249:183:595:225", "ColdridgePass:225:276:360:340", "ColdridgeValley:398:302:100:366", "FrostmaneFront:226:335:469:256", "FrostmaneHold:437:249:50:227", "Gnomeregan:409:318:0:27", "GolBolarQuarry:198:251:663:288", "HelmsBedLake:218:234:760:268", "IceFlowLake:236:358:263:0", "Ironforge:376:347:398:0", "IronforgeAirfield:308:335:630:0", "Kharanos:184:188:449:220", "NorthGateOutpost:237:366:765:43", "TheGrizzledDen:211:160:374:287", "TheShimmeringDeep:171:234:397:132", "TheTundridHills:174:249:579:306",},
	["Duskwood"] = {"AddlesStead:299:296:32:348", "BrightwoodGrove:279:399:497:112", "Darkshire:329:314:640:128", "ManorMistmantle:219:182:661:122", "RacenHill:205:157:96:292", "RavenHillCemetary:323:309:91:132", "TheDarkenedBank:931:235:71:26", "TheHushedBank:189:307:0:152", "TheRottingOrchard:291:263:539:368", "TheTranquilGardensCemetary:291:244:627:344", "TheTwilightGrove:320:388:314:101", "TheYorgenFarmstead:233:248:401:396", "VulGolOgreMound:268:282:228:355",},
	["EasternPlaguelands"] = {"Acherus:228:273:774:102", "BlackwoodLake:238:231:382:151", "CorinsCrossing:186:213:493:289", "CrownGuardTower:202:191:258:351", "Darrowshire:248:206:211:462", "EastwallTower:181:176:541:184", "LakeMereldar:266:241:462:427", "LightsHopeChapel:196:220:687:271", "LightsShieldTower:243:162:391:271", "Northdale:265:232:570:61", "NorthpassTower:250:192:401:69", "Plaguewood:328:253:144:40", "QuelLithienLodge:277:175:351:0", "RuinsOfTheScarletEnclave:264:373:738:295", "Stratholme:310:178:118:0", "Terrordale:258:320:0:10", "TheFungalVale:274:216:183:211", "TheInfectisScar:177:266:595:263", "TheMarrisStead:202:202:133:335", "TheNoxiousGlade:297:299:650:55", "ThePestilentScar:182:320:383:348", "TheUndercroft:280:211:56:457", "ThondorilRiver:262:526:0:100", "Tyrshand:214:254:651:414", "ZulMashar:286:176:528:0",},
	["Elwynn"] = {"BrackwellPumpkinPatch:287:216:532:424", "CrystalLake:220:207:417:327", "EastvaleLoggingCamp:294:243:703:292", "FargodeepMine:269:248:240:420", "Goldshire:276:231:247:294", "JerodsLanding:230:206:396:430", "NorthshireValley:295:296:355:138", "RidgepointTower:285:194:708:442", "StonecairnLake:340:272:552:186", "Stromwind:512:422:0:0", "TowerofAzora:270:241:529:287", "WestbrookGarrison:269:313:116:355",},
	["Ghostlands"] = {"AmaniPass:404:436:598:232", "BleedingZiggurat:256:256:184:238", "DawnstarSpire:427:256:575:0", "Deatholme:512:293:95:375", "ElrendarCrossing:512:256:326:0", "FarstriderEnclave:429:256:573:136", "GoldenmistVillage:512:512:44:0", "HowlingZiggurat:256:449:340:219", "IsleofTribulations:256:256:585:0", "SanctumoftheMoon:256:256:210:126", "SanctumoftheSun:256:512:448:150", "SuncrownVillage:512:256:460:0", "ThalassiaPass:256:262:364:406", "Tranquillien:256:512:365:2", "WindrunnerSpire:256:256:40:287", "WindrunnerVillage:256:512:60:117", "ZebNowa:512:431:466:237",},
	["HillsbradFoothills"] = {"AzurelodeMine:180:182:287:399", "ChillwindPoint:447:263:555:68", "CorrahnsDagger:135:160:426:224", "CrushridgeHold:134:124:463:101", "DalaranCrater:316:238:102:137", "DandredsFold:258:113:341:0", "DarrowHill:147:160:425:279", "DunGarok:269:258:542:410", "DurnholdeKeep:437:451:565:217", "GallowsCorner:155:147:451:140", "GavinsNaze:116:129:344:254", "GrowlessCave:171:136:359:191", "HillsbradFields:302:175:191:302", "LordamereInternmentCamp:250:167:194:216", "MistyShore:158:169:321:42", "NethanderSteed:204:244:502:373", "PurgationIsle:144:139:200:505", "RuinsOfAlterac:189:181:347:85", "SlaughterHollow:148:120:413:55", "SoferasNaze:148:146:484:166", "SouthpointTower:312:254:59:310", "Southshore:229:219:383:352", "Strahnbrad:275:193:505:44", "TarrenMill:165:203:494:226", "TheHeadland:105:148:390:255", "TheUplands:212:160:441:0",},
	["Hinterlands"] = {"AeriePeak:238:267:0:236", "Agolwatha:208:204:367:159", "JinthaAlor:287:289:487:334", "PlaguemistRavine:191:278:133:105", "QuelDanilLodge:241:211:220:181", "Seradane:303:311:475:5", "ShadraAlor:240:196:220:379", "Shaolwatha:281:261:565:208", "SkulkRock:176:235:490:195", "TheAltarofZul:225:196:357:343", "TheCreepingRuin:199:199:390:252", "TheOverlookCliffs:244:401:677:267", "ValorwindLake:199:212:286:269", "Zunwatha:226:225:152:284",},
	["LochModan"] = {"GrizzlepawRidge:273:230:245:324", "IronbandsExcavationSite:397:291:481:296", "MogroshStronghold:294:249:549:52", "NorthgatePass:319:289:16:0", "SilverStreamMine:225:252:221:0", "StonesplinterValley:273:294:177:345", "StronewroughtDam:333:200:339:0", "TheFarstriderLodge:349:292:570:209", "TheLoch:330:474:340:81", "Thelsamar:455:295:0:146", "ValleyofKings:310:345:0:311",},
	["Redridge"] = {"AlthersMill:228:247:350:139", "CampEverstill:189:193:445:286", "GalardellValley:428:463:574:0", "LakeEverstill:464:250:81:214", "LakeridgeHighway:392:352:148:316", "Lakeshire:410:256:0:110", "RedridgeCanyons:413:292:37:0", "RendersCamp:357:246:214:0", "RendersValley:427:291:451:377", "ShalewindCanyon:306:324:688:283", "StonewatchFalls:316:182:525:302", "StonewatchKeep:228:420:480:0", "ThreeCorners:323:406:0:256",},
	["RuinsofGilneas"] = {"GilneasPuzzle:1002:668:0:0",},
	["Gilneas"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
	["Gilneas_terrain1"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
	["Gilneas_terrain2"] = {"NorthgateWoods:282:298:482:14", "GilneasCity:282:263:483:210", "StormglenVillage:321:203:516:465", "HammondFarmstead:194:236:167:352", "HaywardFishery:177:219:293:449", "TempestsReach:350:345:652:290", "TheHeadlands:328:336:160:0", "Duskhaven:286:178:272:333", "NorthernHeadlands:267:314:387:0", "Keelharbor:280:342:298:95", "CrowleyOrchard:210:166:261:427", "EmberstoneMine:281:351:639:43", "Greymanemanor:244:241:141:202", "KorothsDen:222:268:393:386", "TheBlackwald:280:224:504:394",},
	["SearingGorge"] = {"BlackcharCave:375:307:0:361", "BlackrockMountain:304:244:243:424", "DustfireValley:392:355:588:0", "FirewatchRidge:365:393:0:75", "GrimsiltWorksite:441:266:531:241", "TannerCamp:571:308:413:360", "TheCauldron:481:360:232:171", "ThoriumPoint:429:301:255:38",},
	["Silverpine"] = {"Ambermill:283:243:509:250", "BerensPeril:318:263:505:405", "DeepElemMine:217:198:483:212", "FenrisIsle:352:302:581:15", "ForsakenHighCommand:361:175:445:0", "ForsakenRearGuard:186:238:369:0", "NorthTidesBeachhead:174:199:323:68", "NorthTidesRun:281:345:147:0", "OlsensFarthing:251:167:312:249", "ShadowfangKeep:179:165:337:337", "TheBattlefront:255:180:349:429", "TheDecrepitFields:176:152:471:156", "TheForsakenFront:152:189:433:327", "TheGreymaneWall:409:162:318:506", "TheSepulcher:218:200:341:157", "TheSkitteringDark:227:172:236:0", "ValgansField:162:172:461:77",},
	["StranglethornJungle"] = {"BalAlRuins:159:137:267:168", "BaliaMahRuins:239:205:397:243", "Bambala:190:176:566:164", "FortLivingston:230:170:398:375", "GromGolBaseCamp:167:179:298:228", "KalAiRuins:139:150:354:184", "KurzensCompound:244:238:499:0", "LakeNazferiti:240:228:413:95", "Mazthoril:350:259:488:364", "MizjahRuins:157:173:387:246", "MoshOggOgreMound:234:206:543:253", "NesingwarysExpedition:227:190:306:63", "RebelCamp:302:166:306:0", "RuinsOfZulKunda:228:265:158:0", "TheVileReef:236:224:140:208", "ZulGurub:376:560:626:0", "ZuuldalaRuins:324:263:9:22",},
	["Sunwell"] = {"SunsReachHarbor:512:416:252:252", "SunsReachSanctum:512:512:251:4",},
	["SwampOfSorrows"] = {"Bogpaddle:262:193:600:0", "IthariusCave:268:316:7:242", "MarshtideWatch:330:342:478:0", "MistyreedStrand:402:668:600:0", "MistyValley:268:285:0:80", "PoolOfTears:257:229:575:238", "Sorrowmurk:229:418:703:80", "SplinterspearJunction:238:343:194:236", "Stagalbog:347:303:540:360", "Stonard:357:308:297:258", "TheHarborage:266:284:161:79", "TheShiftingMire:292:360:331:24",},
	["TheCapeOfStranglethorn"] = {"BootyBay:225:255:289:341", "CrystalveinMine:271:204:528:73", "GurubashiArena:238:260:345:0", "HardwrenchHideaway:356:221:208:116", "JagueroIsle:240:264:471:404", "MistvaleValley:253:242:408:248", "NekmaniWellspring:246:221:292:213", "RuinsofAboraz:184:176:533:181", "RuinsofJubuwal:155:221:468:119", "TheSundering:244:209:452:0", "WildShore:236:276:340:392",},
	["Tirisfal"] = {"AgamandMills:285:260:324:90", "BalnirFarmstead:242:179:594:324", "BrightwaterLake:210:292:573:122", "Brill:199:182:480:252", "CalstonEstate:179:169:389:255", "ColdHearthManor:212:177:418:317", "CrusaderOutpost:175:210:686:232", "Deathknell:431:407:9:207", "GarrensHaunt:190:214:477:129", "NightmareVale:225:281:347:325", "RuinsofLorderon:390:267:423:359", "ScarletMonastery:262:262:740:47", "ScarletWatchPost:161:234:692:99", "SollidenFarmstead:286:225:201:192", "TheBulwark:293:338:709:330", "VenomwebVale:250:279:752:150",},
	["TwilightHighlands"] = {"Bloodgulch:215:157:416:205", "CrucibleOfCarnage:203:208:387:268", "Crushblow:182:195:370:447", "DragonmawPass:283:206:76:120", "DragonmawPort:251:207:631:245", "DunwaldRuins:197:218:395:367", "FirebeardsPatrol:215:181:499:265", "GlopgutsHollow:174:190:291:89", "GorshakWarCamp:194:170:543:220", "GrimBatol:230:276:83:223", "Highbank:220:227:697:403", "HighlandForest:239:232:482:330", "HumboldtConflaguration:143:141:344:89", "Kirthaven:308:267:482:0", "ObsidianForest:342:288:436:380", "RuinsOfDrakgor:206:182:296:0", "SlitheringCove:198:201:622:169", "TheBlackBreach:211:210:498:121", "TheGullet:175:180:269:179", "TheKrazzworks:226:232:654:0", "TheTwilightBreach:199:212:312:192", "TheTwilightCitadel:361:354:151:314", "TheTwilightGate:165:199:327:356", "Thundermar:238:229:374:93", "TwilightShore:260:202:610:345", "VermillionRedoubt:324:264:71:16", "VictoryPoint:177:159:302:306", "WeepingWound:214:190:358:0", "WyrmsBend:191:198:205:232",},
	["TwilightHighlands_terrain1"] = {"Bloodgulch:215:157:416:205", "CrucibleOfCarnage:203:208:387:268", "Crushblow:182:195:370:447", "DragonmawPass:283:206:76:120", "DragonmawPort:251:207:631:245", "DunwaldRuins:197:218:395:367", "FirebeardsPatrol:215:181:499:265", "GlopgutsHollow:174:190:291:89", "GorshakWarCamp:194:170:543:220", "GrimBatol:230:276:83:223", "Highbank:220:227:697:403", "HighlandForest:239:232:482:330", "HumboldtConflaguration:143:141:344:89", "Kirthaven:308:267:482:0", "ObsidianForest:342:288:436:380", "RuinsOfDrakgor:206:182:296:0", "SlitheringCove:198:201:622:169", "TheBlackBreach:211:210:498:121", "TheGullet:175:180:269:179", "TheKrazzworks:226:232:654:0", "TheTwilightBreach:199:212:312:192", "TheTwilightCitadel:361:354:151:314", "TheTwilightGate:165:199:327:356", "Thundermar:238:229:374:93", "TwilightShore:260:202:610:345", "VermillionRedoubt:324:264:71:16", "VictoryPoint:177:159:302:306", "WeepingWound:214:190:358:0", "WyrmsBend:191:198:205:232",},
	["WesternPlaguelands"] = {"Andorhal:464:325:96:343", "CaerDarrow:194:208:601:390", "DalsonsFarm:325:192:300:232", "DarrowmereLake:492:314:510:354", "FelstoneField:241:212:229:228", "GahrronsWithering:241:252:495:213", "Hearthglen:432:271:235:0", "NorthridgeLumberCamp:359:182:231:123", "RedpineDell:290:133:286:211", "SorrowHill:368:220:261:448", "TheBulwark:316:316:48:235", "TheWeepingCave:185:230:551:151", "TheWrithingHaunt:169:195:472:332", "ThondrorilRiver:311:436:533:0",},
	["Westfall"] = {"AlexstonFarmstead:346:222:167:263", "DemontsPlace:201:195:203:376", "FurlbrowsPumpkinFarm:197:213:394:0", "GoldCoastQuarry:235:306:199:79", "JangoloadMine:196:229:311:0", "Moonbrook:232:213:308:325", "SaldeansFarm:244:237:451:81", "SentinelHill:229:265:404:226", "TheDaggerHills:292:273:303:395", "TheDeadAcre:193:273:531:200", "TheDustPlains:317:261:480:378", "TheGapingChasm:184:217:294:168", "TheJansenStead:202:179:474:0", "TheMolsenFarm:202:224:348:118", "WestfallLighthouse:211:167:221:477",},
	["Wetlands"] = {"AngerfangEncampment:236:256:359:201", "BlackChannelMarsh:301:232:37:240", "BluegillMarsh:321:248:31:102", "DireforgeHills:329:228:506:34", "DunAlgaz:298:215:346:419", "DunModr:257:185:356:7", "GreenwardensGrove:250:269:460:102", "IronbeardsTomb:185:224:372:76", "MenethilHarbor:325:363:0:297", "MosshideFen:369:235:506:232", "RaptorRidge:256:245:599:123", "Satlspray:250:282:218:0", "SlabchiselsSurvey:300:316:532:352", "SundownMarsh:276:243:121:63", "ThelganRock:258:207:371:335", "WhelgarsExcavationSite:298:447:185:195",},

	-- Kalimdor
	["AhnQirajTheFallenKingdom"] = {"AQKingdom:887:668:115:0",},
	["Ashenvale"] = {"Astranaar:251:271:255:164", "BoughShadow:166:211:836:148", "FallenSkyLake:287:276:529:385", "FelfireHill:277:333:714:317", "LakeFalathim:184:232:112:148", "MaelstrasPost:246:361:188:0", "NightRun:221:257:595:253", "OrendilsRetreat:244:251:143:0", "RaynewoodRetreat:231:256:481:221", "Satyrnaar:235:236:696:154", "SilverwindRefuge:347:308:338:335", "TheHowlingVale:325:239:473:97", "TheRuinsofStardust:236:271:210:331", "TheShrineofAssenia:306:283:40:275", "TheZoramStrand:262:390:0:0", "ThistlefurVillage:314:241:255:78", "ThunderPeak:203:310:377:121", "WarsongLumberCamp:231:223:771:265",},
	["Aszhara"] = {"BearsHead:256:224:113:141", "BilgewaterHarbor:587:381:395:127", "BitterReaches:321:247:477:0", "BlackmawHold:260:267:204:53", "DarnassianBaseCamp:243:262:343:3", "GallywixPleasurePalace:250:230:70:222", "LakeMennar:210:232:245:377", "OrgimmarRearGate:352:274:22:344", "RavencrestMonument:295:267:476:401", "RuinsofArkkoran:219:193:575:121", "RuinsofEldarath:218:237:228:229", "StormCliffs:207:232:407:403", "TheSecretLab:184:213:353:396", "TheShatteredStrand:206:329:316:168", "TowerofEldara:306:337:684:22",},
	["AzuremystIsle"] = {"AmmenFord:256:256:515:279", "AmmenVale:475:512:527:104", "AzureWatch:256:256:383:249", "BristlelimbVillage:256:256:174:363", "Emberglade:256:256:488:24", "FairbridgeStrand:256:128:356:0", "GreezlesCamp:256:256:507:350", "MoongrazeWoods:256:256:449:183", "OdesyusLanding:256:256:352:378", "PodCluster:256:256:281:305", "PodWreckage:128:256:462:349", "SiltingShore:256:256:291:3", "SilvermystIsle:256:222:23:446", "StillpineHold:256:256:365:49", "TheExodar:512:512:74:85", "ValaarsBerth:256:256:176:303", "WrathscalePoint:256:247:220:421",},
	["Barrens"] = {"BoulderLodeMine:278:209:511:7", "DreadmistPeak:241:195:290:104", "FarWatchPost:207:332:555:129", "GroldomFarm:243:217:448:127", "MorshanRampart:261:216:258:6", "Ratchet:219:175:547:379", "TheCrossroads:233:193:362:275", "TheDryHills:283:270:116:57", "TheForgottenPools:446:256:100:208", "TheMerchantCoast:315:212:556:456", "TheSludgeFen:257:249:403:6", "TheStagnantOasis:336:289:344:379", "TheWailingCaverns:377:325:152:318", "ThornHill:239:231:481:254",},
	["BloodmystIsle"] = {"AmberwebPass:256:512:44:62", "Axxarien:256:256:297:136", "BlacksiltShore:512:242:177:426", "Bladewood:256:256:367:209", "BloodscaleIsle:239:256:763:256", "BloodWatch:256:256:437:258", "BristlelimbEnclave:256:256:546:410", "KesselsCrossing:485:141:517:527", "Middenvale:256:256:414:406", "Mystwood:256:185:309:483", "Nazzivian:256:256:250:404", "RagefeatherRidge:256:256:481:117", "RuinsofLorethAran:256:256:556:216", "TalonStand:256:256:657:78", "TelathionsCamp:128:128:180:216", "TheBloodcursedReef:256:256:729:54", "TheBloodwash:256:256:302:27", "TheCrimsonReach:256:256:555:87", "TheCryoCore:256:256:293:285", "TheFoulPool:256:256:221:136", "TheHiddenReef:256:256:205:39", "TheLostFold:256:198:503:470", "TheVectorCoil:512:430:43:238", "TheWarpPiston:256:256:451:29", "VeridianPoint:256:256:637:0", "VindicatorsRest:256:256:232:242", "WrathscaleLair:256:256:598:338", "WyrmscarIsland:256:256:613:82",},
	["Desolace"] = {"CenarionWildlands:312:285:415:156", "GelkisVillage:274:196:207:472", "KodoGraveyard:250:215:360:273", "MagramTerritory:289:244:613:170", "MannorocCoven:326:311:381:357", "NijelsPoint:231:257:573:0", "RanzjarIsle:161:141:210:0", "Sargeron:317:293:655:0", "ShadowbreakRavine:292:266:637:402", "ShadowpreyVillage:222:299:142:369", "ShokThokar:309:349:589:319", "SlitherbladeShore:338:342:208:24", "TethrisAran:274:145:399:0", "ThargadsCamp:212:186:275:376", "ThunderAxeFortress:220:205:440:49", "ValleyofSpears:321:275:170:196",},
	["Durotar"] = {"DrygulchRavine:236:196:415:60", "EchoIsles:330:255:429:413", "NorthwatchFoothold:162:157:399:440", "Orgrimmar:259:165:309:0", "RazorHill:224:227:431:157", "RazormaneGrounds:248:158:302:264", "SenjinVillage:192:184:457:406", "SkullRock:208:157:438:0", "SouthfuryWatershed:244:222:282:174", "ThunderRidge:220:218:295:48", "TiragardeKeep:210:200:462:298", "ValleyOfTrials:254:258:304:312",},
	["Dustwallow"] = {"AlcazIsland:206:200:656:21", "BlackhoofVillage:344:183:199:0", "BrackenwllVillage:384:249:133:59", "DirehornPost:279:301:358:169", "Mudsprocket:433:351:109:313", "ShadyRestInn:317:230:137:188", "TheramoreIsle:305:247:542:223", "TheWyrmbog:436:299:359:369", "WitchHill:270:353:428:0",},
	["Dustwallow_terrain1"] = {"AlcazIsland:206:200:656:21", "BlackhoofVillage:344:183:199:0", "BrackenwllVillage:384:249:133:59", "DirehornPost:279:301:358:169", "Mudsprocket:433:351:109:313", "ShadyRestInn:317:230:137:188", "TheramoreIsle:305:247:542:223", "TheWyrmbog:436:299:359:369", "WitchHill:270:353:428:0",},
	["EversongWoods"] = {"AzurebreezeCoast:256:256:669:228", "DuskwitherGrounds:256:256:605:253", "EastSanctum:256:256:460:373", "ElrendarFalls:128:256:580:399", "FairbreezeVilliage:256:256:386:386", "FarstriderRetreat:256:128:524:359", "GoldenboughPass:256:128:243:469", "LakeElrendar:128:197:584:471", "NorthSanctum:256:256:361:298", "RuinsofSilvermoon:256:256:307:136", "RunestoneFalithas:256:172:378:496", "RunestoneShandor:256:174:464:494", "SatherilsHaven:256:256:324:384", "SilvermoonCity:512:512:440:87", "StillwhisperPond:256:256:474:314", "SunsailAnchorage:256:128:231:404", "SunstriderIsle:512:512:195:5", "TheGoldenStrand:128:253:183:415", "TheLivingWood:128:248:511:420", "TheScortchedGrove:256:128:255:507", "ThuronsLivery:256:128:539:305", "TorWatha:256:353:648:315", "TranquilShore:256:256:215:298", "WestSanctum:128:256:292:319", "Zebwatha:128:193:554:475",},
	["Felwood"] = {"BloodvenomFalls:345:192:220:231", "DeadwoodVillage:173:163:410:505", "EmeraldSanctuary:274:212:394:382", "FelpawVillage:307:161:471:0", "IrontreeWoods:261:273:406:55", "JadefireGlen:229:210:288:458", "JadefireRun:263:199:303:9", "Jaedenar:319:176:234:317", "MorlosAran:187:176:476:484", "RuinsofConstellas:268:214:278:359", "ShatterScarVale:343:250:243:107", "TalonbranchGlade:209:226:531:57",},
	["Feralas"] = {"CampMojache:174:220:671:181", "DarkmistRuins:172:198:568:287", "DireMaul:265:284:485:101", "FeathermoonStronghold:217:192:362:237", "FeralScar:191:179:457:281", "GordunniOutpost:192:157:663:116", "GrimtotemCompund:159:218:607:170", "LowerWilds:207:209:756:191", "RuinsofFeathermoon:208:204:186:229", "RuinsofIsildien:206:237:467:354", "TheForgottenCoast:194:304:375:343", "TheTwinColossals:350:334:271:0", "WrithingDeep:232:206:652:298",},
	["Hyjal"] = {"ArchimondesVengeance:270:300:320:5", "AshenLake:282:418:6:78", "DarkwhisperGorge:320:471:682:128", "DireforgeHill:270:173:303:197", "GatesOfSothann:272:334:622:320", "Nordrassil:537:323:392:0", "SethriasRoost:277:232:139:436", "ShrineOfGoldrinn:291:321:116:17", "TheRegrowth:441:319:52:253", "TheScorchedPlain:365:264:411:216", "TheThroneOfFlame:419:290:318:378",},
	["Hyjal_terrain1"] = {"ArchimondesVengeance:270:300:320:5", "AshenLake:282:418:6:78", "DarkwhisperGorge:320:471:682:128", "DireforgeHill:270:173:303:197", "GatesOfSothann:272:334:622:320", "Nordrassil:537:323:392:0", "SethriasRoost:277:232:139:436", "ShrineOfGoldrinn:291:321:116:17", "TheRegrowth:441:319:52:253", "TheScorchedPlain:365:264:411:216", "TheThroneOfFlame:419:290:318:378",},
	["Moonglade"] = {"LakeEluneara:431:319:219:273", "Nighthaven:346:244:370:135", "ShrineofRemulos:271:296:209:91", "StormrageBarrowDens:275:346:542:210",},
	["Mulgore"] = {"BaeldunDigsite:218:192:226:220", "BloodhoofVillage:302:223:319:273", "PalemaneRock:172:205:248:321", "RavagedCaravan:187:165:435:224", "RedCloudMesa:446:264:286:401", "RedRocks:186:185:514:43", "StonetalonPass:237:184:201:0", "TheGoldenPlains:186:216:448:101", "TheRollingPlains:260:243:527:291", "TheVentureCoMine:208:300:530:138", "ThunderBluff:373:259:208:62", "ThunderhornWaterWell:201:167:333:202", "WildmaneWaterWell:190:172:331:0", "WindfuryRidge:222:202:400:0", "WinterhoofWaterWell:174:185:449:340",},
	["Silithus"] = {"CenarionHold:292:260:427:143", "HiveAshi:405:267:345:4", "HiveRegal:489:358:380:310", "HiveZora:542:367:0:206", "SouthwindVillage:309:243:550:181", "TheCrystalVale:329:246:126:0", "TheScarabWall:580:213:0:455", "TwilightBaseCamp:434:231:100:151", "ValorsRest:315:285:614:0",},
	["SouthernBarrens"] = {"BaelModan:269:211:398:457", "Battlescar:384:248:274:307", "ForwardCommand:216:172:423:251", "FrazzlecrazMotherload:242:195:269:436", "HonorsStand:315:170:201:0", "HuntersHill:218:178:300:64", "NorthwatchHold:280:279:548:147", "RazorfenKraul:214:140:273:528", "RuinsofTaurajo:285:171:244:286", "TheOvergrowth:355:226:289:117", "VendettaPoint:254:214:267:196",},
	["StonetalonMountains"] = {"BattlescarValley:290:297:220:189", "BoulderslideRavine:194:156:532:512", "CliffwalkerPost:241:192:366:95", "GreatwoodVale:322:220:602:448", "KromgarFortress:183:196:588:341", "Malakajin:211:131:618:537", "MirkfallonLake:244:247:417:143", "RuinsofEldrethar:221:235:367:411", "StonetalonPeak:305:244:265:0", "SunRockRetreat:222:222:353:285", "ThaldarahOverlook:210:189:252:121", "TheCharredVale:277:274:199:368", "UnearthedGrounds:265:206:654:369", "WebwinderHollow:164:258:479:401", "WebwinderPath:267:352:468:263", "WindshearCrag:374:287:533:179", "WindshearHold:176:189:516:289",},
	["Tanaris"] = {"AbyssalSands:255:194:297:148", "BrokenPillar:195:163:413:211", "CavernsofTime:213:173:507:238", "DunemaulCompound:231:177:305:257", "EastmoonRuins:173:163:380:341", "Gadgetzan:189:180:412:92", "GadgetzanBay:254:341:479:9", "LandsEndBeach:224:216:431:452", "LostRiggerCover:178:243:615:201", "SandsorrowWatch:214:149:293:99", "SouthbreakShore:274:186:437:289", "SouthmoonRuins:232:211:301:349", "TheGapingChasm:225:187:448:364", "TheNoxiousLair:179:190:258:211", "ThistleshrubValley:221:293:185:280", "ValleryoftheWatchers:269:190:255:431", "ZulFarrak:315:190:184:0",},
	["Teldrassil"] = {"BanethilHollow:175:235:374:221", "Darnassus:298:337:149:181", "GalardellValley:178:186:466:237", "GnarlpineHold:198:181:347:355", "LakeAlameth:289:202:422:310", "PoolsofArlithrien:140:210:345:243", "RutheranVillage:317:220:329:448", "Shadowglen:241:217:481:104", "StarbreezeVillage:187:196:544:217", "TheCleft:144:226:432:109", "TheOracleGlade:194:244:276:90", "WellspringLake:165:249:382:83",},
	["ThousandNeedles"] = {"DarkcloudPinnacle:317:252:169:116", "FreewindPost:436:271:276:186", "Highperch:246:380:0:134", "RazorfenDowns:361:314:298:0", "RustmaulDiveSite:234:203:527:465", "SouthseaHoldfast:246:256:756:412", "SplithoofHeights:431:410:571:49", "TheGreatLift:272:232:136:0", "TheShimmeringDeep:411:411:591:257", "TheTwilightWithering:374:339:347:329", "TwilightBulwark:358:418:125:241", "WestreachSummit:280:325:0:0",},
	["Uldum"] = {"AkhenetFields:164:185:471:277", "CradelOfTheAncient:202:169:341:402", "HallsOfOrigination:269:242:599:184", "KhartutsTomb:203:215:542:0", "LostCityOfTheTolVir:233:321:527:291", "Marat:160:193:406:174", "Nahom:237:194:583:162", "Neferset:209:254:407:384", "ObeliskOfTheMoon:400:224:110:0", "ObeliskOfTheStars:196:170:551:121", "ObeliskOfTheSun:269:203:340:282", "Orsis:249:243:264:136", "Ramkahen:228:227:411:67", "RuinsOfAhmtul:278:173:365:0", "RuinsOfAmmon:203:249:217:289", "Schnottzslanding:312:289:28:221", "TahretGrounds:150:159:545:193", "TempleofUldum:296:209:132:127", "TheCursedlanding:237:316:752:170", "TheGateofUnendingCycles:161:236:647:15", "TheTrailOfDevestation:206:204:657:349", "TheVortexPinnacle:213:195:656:473", "ThroneOfTheFourWinds:270:229:229:433", "VirnaalDam:151:144:479:215",},
	["Uldum_terrain1"] = {"AkhenetFields:164:185:471:277", "CradelOfTheAncient:202:169:341:402", "HallsOfOrigination:269:242:599:184", "KhartutsTomb:203:215:542:0", "LostCityOfTheTolVir:233:321:527:291", "Marat:160:193:406:174", "Nahom:237:194:583:162", "Neferset:209:254:407:384", "ObeliskOfTheMoon:400:224:110:0", "ObeliskOfTheStars:196:170:551:121", "ObeliskOfTheSun:269:203:340:282", "Orsis:249:243:264:136", "Ramkahen:228:227:411:67", "RuinsOfAhmtul:278:173:365:0", "RuinsOfAmmon:203:249:217:289", "Schnottzslanding:312:289:28:221", "TahretGrounds:150:159:545:193", "TempleofUldum:296:209:132:127", "TheCursedlanding:237:316:752:170", "TheGateofUnendingCycles:161:236:647:15", "TheTrailOfDevestation:206:204:657:349", "TheVortexPinnacle:213:195:656:473", "ThroneOfTheFourWinds:270:229:229:433", "VirnaalDam:151:144:479:215",},
	["UngoroCrater"] = {"FirePlumeRidge:321:288:356:192", "FungalRock:224:191:557:0", "GolakkaHotSprings:309:277:145:226", "IronstonePlateau:197:222:706:201", "LakkariTarPits:432:294:305:0", "MarshalsStand:204:170:462:330", "MossyPile:186:185:328:179", "TerrorRun:316:293:162:357", "TheMarshlands:263:412:573:256", "TheRollingGarden:337:321:565:39", "TheScreamingReaches:332:332:157:0", "TheSlitheringScar:381:274:335:384",},
	["Winterspring"] = {"Everlook:194:229:482:195", "FrostfireHotSprings:376:289:93:118", "FrostsaberRock:332:268:304:0", "FrostwhisperGorge:317:183:424:474", "IceThistleHills:249:217:581:314", "LakeKeltheril:271:258:372:268", "Mazthoril:257:238:399:340", "OwlWingThicket:254:150:556:439", "StarfallVillage:367:340:229:33", "TheHiddenGrove:333:255:500:17", "TimbermawPost:362:252:92:302", "WinterfallVillage:221:209:588:181",},

	-- Outland
	["BladesEdgeMountains"] = {"BashirLanding:256:256:422:0", "BladedGulch:256:256:623:147", "BladesipreHold:256:507:314:161", "BloodmaulCamp:256:256:412:95", "BloodmaulOutpost:256:297:342:371", "BrokenWilds:256:256:733:109", "CircleofWrath:256:256:439:210", "DeathsDoor:256:419:512:249", "ForgeCampAnger:416:256:586:147", "ForgeCampTerror:512:252:144:416", "ForgeCampWrath:256:256:254:176", "Grishnath:256:256:286:28", "GruulsLayer:256:256:527:81", "JaggedRidge:256:254:446:414", "MokNathalVillage:256:256:658:297", "RavensWood:512:256:214:55", "RazorRidge:256:336:533:332", "RidgeofMadness:256:410:554:258", "RuuanWeald:256:512:479:98", "Skald:256:256:673:71", "Sylvanaar:256:318:289:350", "TheCrystalpine:256:256:585:0", "ThunderlordStronghold:256:396:405:272", "VeilLashh:256:240:271:428", "VeilRuuan:256:128:563:151", "VekhaarStand:256:256:629:406", "VortexPinnacle:256:462:166:206",},
	["Hellfire"] = {"DenofHaalesh:256:256:182:412", "ExpeditionArmory:512:255:261:413", "FalconWatch:512:342:183:326", "FallenSkyRidge:256:256:34:142", "ForgeCampRage:512:512:478:25", "HellfireCitadel:256:458:338:210", "HonorHold:256:256:469:298", "MagharPost:256:256:206:110", "PoolsofAggonar:256:512:326:45", "RuinsofShanaar:256:378:25:290", "TempleofTelhamat:512:512:38:152", "TheLegionFront:256:512:579:128", "TheStairofDestiny:256:512:737:156", "Thrallmar:256:256:467:154", "ThroneofKiljaeden:512:256:477:6", "VoidRidge:256:256:705:368", "WarpFields:256:260:308:408", "ZethGor:422:238:580:430",},
	["Nagrand"] = {"BurningBladeRUins:256:334:660:334", "ClanWatch:256:256:532:363", "ForgeCampFear:512:420:36:248", "ForgeCampHate:256:256:162:154", "Garadar:256:256:431:143", "Halaa:256:256:335:193", "KilsorrowFortress:256:241:558:427", "LaughingSkullRuins:256:256:351:52", "OshuGun:512:334:168:334", "RingofTrials:256:256:533:267", "SouthwindCleft:256:256:391:258", "SunspringPost:256:256:219:199", "Telaar:256:256:387:390", "ThroneoftheElements:256:256:504:53", "TwilightRidge:256:512:10:107", "WarmaulHill:256:256:157:32", "WindyreedPass:256:256:598:79", "WindyreedVillage:256:256:666:233", "ZangarRidge:256:256:277:54",},
	["Netherstorm"] = {"Area52:256:128:241:388", "ArklonRuins:256:256:328:397", "CelestialRidge:256:256:644:173", "EcoDomeFarfield:256:256:396:10", "EtheriumStagingGrounds:256:256:481:208", "ForgeBaseOG:256:256:237:22", "KirinVarVillage:256:145:490:523", "ManaforgeBanar:256:387:147:281", "ManaforgeCoruu:256:179:357:489", "ManaforgeDuro:256:256:465:336", "ManafrogeAra:256:256:171:155", "Netherstone:256:256:411:20", "NetherstormBridge:256:256:132:294", "RuinedManaforge:256:256:513:138", "RuinsofEnkaat:256:256:253:301", "RuinsofFarahlon:512:256:354:49", "SocretharsSeat:256:256:229:38", "SunfuryHold:256:217:454:451", "TempestKeep:409:384:593:284", "TheHeap:256:213:239:455", "TheScrapField:256:256:356:261", "TheStormspire:256:256:298:134",},
	["ShadowmoonValley"] = {"AltarofShatar:256:256:520:93", "CoilskarPoint:512:512:348:8", "EclipsePoint:512:358:343:310", "IlladarPoint:256:256:143:256", "LegionHold:512:512:104:155", "NetherwingCliffs:256:256:554:308", "NetherwingLedge:492:223:510:445", "ShadowmoonVilliage:512:512:116:35", "TheBlackTemple:396:512:606:126", "TheDeathForge:256:512:290:129", "TheHandofGuldan:512:512:394:90", "TheWardensCage:512:410:469:258", "WildhammerStronghold:512:439:168:229",},
	["TerokkarForest"] = {"AllerianStronghold:256:256:480:277", "AuchenaiGrounds:256:234:247:434", "BleedingHollowClanRuins:256:367:103:301", "BonechewerRuins:256:256:521:275", "CarrionHill:256:256:377:272", "CenarionThicket:256:256:314:0", "FirewingPoint:385:512:617:149", "GrangolvarVilliage:512:256:143:171", "RaastokGlade:256:256:505:154", "RazorthornShelf:256:256:478:19", "RefugeCaravan:128:256:316:268", "RingofObservance:256:256:310:345", "SethekkTomb:256:256:245:289", "ShattrathCity:512:512:104:4", "SkethylMountains:512:320:449:348", "SmolderingCaravan:256:208:321:460", "StonebreakerHold:256:256:397:165", "TheBarrierHills:256:256:116:4", "Tuurem:256:512:455:34", "VeilRhaze:256:256:222:362", "WrithingMound:256:256:417:327",},
	["Zangarmarsh"] = {"AngoroshGrounds:256:256:88:50", "AngoroshStronghold:256:128:124:0", "BloodscaleEnclave:256:256:596:412", "CenarionRefuge:308:256:694:321", "CoilfangReservoir:256:512:462:90", "FeralfenVillage:512:336:314:332", "MarshlightLake:256:256:81:152", "OreborHarborage:256:512:329:25", "QuaggRidge:256:343:141:325", "Sporeggar:512:256:20:202", "Telredor:256:512:569:112", "TheDeadMire:286:512:716:128", "TheHewnBog:256:512:219:51", "TheLagoon:256:256:512:303", "TheSpawningGlen:256:256:31:339", "TwinspireRuins:256:256:342:249", "UmbrafenVillage:256:207:720:461", "ZabraJin:256:256:175:232",},

	-- Northrend
	["BoreanTundra"] = {"AmberLedge:244:214:325:140", "BorGorokOutpost:396:203:314:0", "Coldarra:460:381:50:0", "DeathsStand:289:279:707:181", "GarroshsLanding:267:378:153:238", "Kaskala:385:316:509:214", "RiplashStrand:382:258:293:383", "SteeljawsCaravan:244:319:397:66", "TempleCityOfEnKilah:290:292:712:15", "TheDensOfDying:203:209:662:11", "TheGeyserFields:375:342:480:0", "TorpsFarm:186:276:272:237", "ValianceKeep:259:302:457:264", "WarsongStronghold:260:278:329:237",},
	["CrystalsongForest"] = {"ForlornWoods:544:668:129:0", "SunreaversCommand:446:369:536:40", "TheAzureFront:416:424:0:244", "TheDecrepitFlow:288:222:0:0", "TheGreatTree:252:260:0:91", "TheUnboundThicket:502:477:500:105", "VioletStand:264:303:0:176", "WindrunnersOverlook:558:285:444:383",},
	["Dragonblight"] = {"AgmarsHammer:236:218:258:203", "Angrathar:306:242:210:0", "ColdwindHeights:213:219:403:0", "EmeraldDragonshrine:196:218:543:362", "GalakrondsRest:258:225:433:118", "IcemistVillage:235:337:134:165", "LakeIndule:356:300:217:313", "LightsRest:299:278:703:7", "Naxxramas:311:272:691:160", "NewHearthglen:214:261:614:358", "ObsidianDragonshrine:304:203:256:104", "RubyDragonshrine:188:211:374:208", "ScarletPoint:235:354:569:7", "TheCrystalVice:229:259:487:0", "TheForgottenShore:301:286:698:332", "VenomSpite:226:212:661:264", "WestwindRefugeeCamp:229:299:42:187", "WyrmrestTemple:317:353:453:219",},
	["GrizzlyHills"] = {"AmberpineLodge:278:290:217:244", "BlueSkyLoggingGrounds:249:235:232:129", "CampOneqwah:324:265:548:137", "ConquestHold:332:294:17:307", "DrakilJinRuins:351:284:607:41", "DrakTheronKeep:382:285:0:46", "DunArgol:455:400:547:257", "GraniteSprings:356:224:7:207", "GrizzleMaw:294:227:358:187", "RageFangShrine:475:362:312:294", "ThorModan:329:246:509:0", "UrsocsDen:328:260:331:32", "VentureBay:274:207:18:461", "Voldrune:283:247:176:421",},
	["HowlingFjord"] = {"AncientLift:177:191:342:351", "ApothecaryCamp:263:265:99:37", "BaelgunsExcavationSite:244:305:621:327", "Baleheim:174:173:576:170", "CampWinterHoof:223:209:354:0", "CauldrosIsle:181:178:490:161", "EmberClutch:213:256:283:203", "ExplorersLeagueOutpost:232:216:585:336", "FortWildervar:251:192:490:0", "GiantsRun:298:306:572:0", "Gjalerbron:242:189:225:0", "Halgrind:187:263:397:208", "IvaldsRuin:193:201:668:223", "Kamagua:333:265:99:278", "NewAgamand:284:308:415:360", "Nifflevar:178:208:595:240", "ScalawagPoint:350:258:168:410", "Skorn:238:232:343:108", "SteelGate:222:168:222:100", "TheTwistedGlade:266:210:420:57", "UtgardeKeep:248:382:477:216", "VengeanceLanding:223:338:664:25", "WestguardKeep:347:220:90:180",},
	["IcecrownGlacier"] = {"Aldurthar:373:375:355:37", "ArgentTournamentGround:314:224:616:30", "Corprethar:308:212:342:392", "IcecrownCitadel:308:202:392:466", "Jotunheim:393:474:22:122", "OnslaughtHarbor:204:268:0:167", "Scourgeholme:245:239:690:267", "SindragosasFall:300:343:626:31", "TheBombardment:248:243:538:181", "TheBrokenFront:283:231:558:329", "TheConflagration:227:210:327:305", "TheFleshwerks:219:283:218:291", "TheShadowVault:223:399:321:15", "Valhalas:238:240:217:50", "ValleyofEchoes:269:217:715:390", "Ymirheim:223:207:444:276",},
	["SholazarBasin"] = {"KartaksHold:329:293:76:375", "RainspeakerCanopy:207:235:427:244", "RiversHeart:468:329:359:339", "TheAvalanche:322:265:596:92", "TheGlimmeringPillar:294:327:308:34", "TheLifebloodPillar:312:369:501:134", "TheMakersOverlook:233:286:705:236", "TheMakersPerch:249:248:172:135", "TheMosslightPillar:239:313:265:355", "TheSavageThicket:293:229:396:51", "TheStormwrightsShelf:268:288:138:58", "TheSuntouchedPillar:455:316:82:186",},
	["TheStormPeaks"] = {"BorsBreath:322:195:109:375", "BrunnhildarVillage:305:298:339:370", "DunNiffelem:309:383:481:285", "EngineoftheMakers:210:179:316:296", "Frosthold:244:220:134:429", "GarmsBane:184:191:395:470", "NarvirsCradle:180:239:214:144", "Nidavelir:221:200:108:206", "SnowdriftPlains:205:232:162:143", "SparksocketMinefield:251:200:242:468", "TempleofLife:182:270:570:113", "TempleofStorms:169:164:239:301", "TerraceoftheMakers:363:341:292:122", "Thunderfall:306:484:627:179", "Ulduar:369:265:218:0", "Valkyrion:228:158:98:318",},
	["ZulDrak"] = {"AltarOfHarKoa:265:257:533:345", "AltarOfMamToth:311:317:575:88", "AltarOfQuetzLun:261:288:607:251", "AltarOfRhunok:247:304:431:127", "AltarOfSseratus:237:248:288:168", "AmphitheaterOfAnguish:266:254:289:287", "DrakSotraFields:286:265:326:358", "GunDrak:336:297:629:0", "Kolramas:302:231:380:437", "LightsBreach:321:305:181:363", "ThrymsEnd:272:268:0:247", "Voltarus:218:291:174:191", "Zeramas:307:256:7:412", "ZimTorga:249:258:479:241",},

	-- Cataclysm
	["Deepholm"] = {"CrimsonExpanse:462:400:540:12", "DeathwingsFall:454:343:549:297", "NeedlerockChasm:378:359:20:0", "NeedlerockSlag:370:285:0:146", "ScouredReach:516:287:448:0", "StoneHearth:371:354:0:314", "StormsFuryWreckage:292:285:458:383", "TempleOfEarth:355:345:287:177", "ThePaleRoost:467:273:85:0", "TherazanesThrone:274:156:434:0", "TheShatteredField:430:230:141:438", "TwilightOverlook:411:248:570:420", "TwilightTerrace:237:198:297:384",},
	["Kezan"] = {"BilgewaterPort:694:290:163:148", "Drudgetown:351:301:180:367", "FirstbankofKezan:376:343:98:325", "GallywixsVilla:303:452:0:41", "Kajamine:354:360:586:308", "KajaroField:250:307:383:260", "KezanMap:1002:664:0:4", "SwindleStreet:168:213:317:232",},
	["TheLostIsles"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
	["TheLostIsles_terrain1"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
	["TheLostIsles_terrain2"] = {"Alliancebeachhead:177:172:129:348", "BilgewaterLumberyard:248:209:462:43", "GallywixDocks:173:180:351:21", "HordeBaseCamp:222:190:244:458", "KTCOilPlatform:156:142:433:11", "landingSite:142:133:377:359", "Lostpeak:350:517:581:21", "OoomlotVillage:221:211:508:345", "Oostan:210:258:492:161", "RaptorRise:168:205:416:368", "RuinsOfVashelan:212:216:440:452", "ScorchedGully:305:288:323:185", "ShipwreckShore:172:175:189:408", "SkyFalls:190:186:416:131", "TheSavageGlen:231:216:213:325", "TheSlavePits:212:193:279:68", "WarchiefsLookout:159:230:264:144",},
	["VashjirDepths"] = {"AbandonedReef:371:394:50:263", "AbyssalBreach:491:470:497:0", "ColdlightChasm:267:374:266:280", "DeepfinRidge:363:262:275:32", "FireplumeTrench:298:251:315:110", "KorthunsEnd:370:385:412:283", "LGhorek:306:293:162:210", "Seabrush:225:250:415:183",},
	["VashjirKelpForest"] = {"DarkwhisperGorge:220:189:528:228", "GnawsBoneyard:311:217:451:325", "GubogglesLedge:227:207:399:280", "HoldingPens:316:267:456:401", "HonorsTomb:291:206:380:43", "LegionsFate:278:315:210:35", "TheAccursedReef:340:225:365:162",},
	["VashjirRuins"] = {"BethMoraRidge:335:223:407:445", "GlimmeringdeepGorge:272:180:270:222", "Nespirah:286:269:460:261", "RuinsOfTherseral:197:223:554:175", "RuinsOfVashjir:349:361:217:268", "ShimmeringGrotto:339:278:400:0", "SilverTideHollow:480:319:150:32",},

	-- Pandaria
	["DreadWastes"] = {"KLAXXIVESS:236:206:458:110", "ZANVESS:290:283:162:385", "BREWGARDEN:250:218:351:0", "DREADWATERLAKE:322:211:437:313", "CLUTCHESOFSHEKZEER:209:318:341:125", "HORRIDMARCH:323:194:441:224", "BRINYMUCK:325:270:214:311", "SOGGYSGAMBLE:268:241:450:406", "TERRACEOFGURTHAN:209:234:593:92", "RIKKITUNVILLAGE:218:186:236:32", "HEARTOFFEAR:262:293:191:122", "KYPARIVOR:325:190:485:0",},
	["Krasarang"] = {"RedwingRefuge:212:265:317:63", "AnglersOutpost:265:194:545:205", "TempleOfTheRedCrane:219:259:300:215", "DojaniRiver:190:282:513:3", "krasarangCove:286:268:701:19", "TheDeepwild:188:412:397:59", "LostDynasty:217:279:589:27", "FallsongRiver:214:393:218:77", "TheSouthernIsles:252:313:23:267", "ZhusBastion:306:204:612:0", "RuinsOfDojan:204:383:444:44", "TheForbiddenJungle:257:300:0:79", "RuinsOfKorja:211:395:125:88", "CradleOfChiJi:272:250:176:376", "UngaIngoo:258:170:330:498", "NayeliLagoon:246:240:343:373",},
	["Krasarang_terrain1"] = {"Zhusbastion:306:204:612:0", "FallsongRiver:214:393:218:77", "DojaniRiver:190:282:513:3", "RuinsOfDojan:204:383:444:44", "TheDeepWild:188:412:397:59", "Nayelilagoon:246:240:343:373", "Ungaingoo:258:170:330:498", "KrasarangCove:295:293:701:19", "RuinsOfKorja:211:395:125:88", "LostDynasty:217:279:589:27", "TheSouthernIsles:275:329:0:267", "AnglerSoutpost:347:199:545:200", "TheForbiddenJungle:257:300:0:79", "RedWingRefuge:212:265:317:63", "TempleOfTheRedCrane:219:259:300:215", "CradleOfChiji:272:250:176:376",},
	["KunLaiSummit"] = {"BinanVillage:240:198:607:470", "Mogujia:253:208:462:411", "MuskpawRanch:229:262:603:313", "MountNeverset:313:208:228:264", "ZouchinVillage:298:219:502:64", "TempleoftheWhitetiger:250:260:587:170", "GateoftheAugust:261:162:449:506", "ShadoPanMonastery:385:385:88:92", "TheBurlapTrail:310:276:398:310", "PeakOfSerenity:287:277:333:63", "ValleyOfEmperors:224:241:453:191", "Kotapeak:252:257:233:360", "Iseoflostsouls:259:233:602:4", "FireboughNook:224:172:322:496", "TEMPLEOFTHEWHITETIGER:250:260:587:170",},
	["TheHiddenPass"] = {"TheHiddenCliffs:294:220:433:0", "TheBlackMarket:479:493:371:175", "TheHiddenSteps:290:191:412:477",},
	["TheJadeForest"] = {"GlassfinVillage:278:310:525:358", "RuinsOfGanShi:196:158:316:0", "TheArboretum:242:210:481:215", "WindlessIsle:251:348:539:43", "DawnsBlossom:234:210:325:178", "TempleOfTheJadeSerpent:264:211:468:295", "DreamersPavillion:218:148:474:520", "NectarbreezeOrchard:219:256:290:330", "HellscreamsHope:196:166:181:75", "SlingtailPits:179:180:428:416", "SerpentsSpine:191:216:388:299", "ChunTianMonastery:227:198:300:56", "JadeMines:236:142:400:146", "EmperorsOmen:202:204:430:21", "GrookinMound:253:229:182:214", "WreckOfTheSkyShark:210:158:202:0", "Waywardlanding:219:186:346:482", "NookaNooka:219:205:189:151",},
	["TheWanderingIsle"] = {"TheDawningValley:677:668:325:0", "TempleofFiveDawns:607:461:395:182", "MandoriVillage:610:374:392:294", "RidgeofLaughingWinds:313:321:183:198", "Pei-WuForest:651:262:351:406", "PoolofthePaw:220:188:297:324", "SkyfireCrash-Site:346:263:124:405", "TheRows:385:373:504:295", "TheSingingPools:372:475:545:12", "MorningBreezeVillage:261:315:203:36", "Fe-FangVillage:234:286:134:9", "TheWoodofStaves:989:466:13:202",},
	["TownlongWastes"] = {"NiuzaoTemple:296:359:213:241", "ShanzeDao:300:246:125:0", "TheSumprushes:271:205:545:369", "Sikvess:261:235:306:433", "GaoRanBlockade:353:200:546:468", "MingChiCrossroads:247:221:417:447", "palewindVillage:282:306:692:362", "OsulMesa:238:296:560:185", "ShadoPanGarrison:213:170:413:385", "KriVess:255:269:420:209", "SriVess:294:283:92:192",},
	["ValeofEternalBlossoms"] = {"GuoLaiRuins:337:349:87:3", "WhiteMoonShrine:298:262:482:10", "MistfallVillage:310:305:200:363", "SettingSunTraining:350:429:0:234", "TuShenBurialGround:267:308:349:316", "TheStairsAscent:446:359:556:267", "WinterboughGlade:361:333:4:107", "TheGoldenStair:242:254:328:16", "WhitepetalLake:267:281:278:170", "TheTwinMonoliths:272:522:444:97", "MoguShanPalace:373:385:629:22",},
	["ValleyoftheFourWinds"] = {"ThunderfootFields:380:317:622:0", "PoolsofPurity:213:246:513:58", "RumblingTerrace:277:245:582:301", "PaoquanHollow:273:246:12:105", "StormsoutBrewery:257:288:227:380", "DustbackGorge:209:308:0:343", "CliffsofDispair:510:264:215:404", "Theheartland:286:392:253:75", "SilkenFields:254:259:530:253", "HarvestHome:260:251:5:239", "GildedFan:208:292:438:41", "GrandGranery:314:212:334:325", "SingingMarshes:175:291:170:130", "ZhusDecent:303:323:699:114", "Halfhill:206:245:438:177", "NesingwarySafari:249:342:104:326", "MudmugsPlace:230:217:561:161", "KuzenVillage:199:304:224:74",},

	-- Draenor
	["FrostfireRidge"] = {"BladespireFortress:356:303:38:117", "BloodmaulStronghold:258:217:311:4", "BonesOfAgurak:273:349:729:319", "DaggermawRavine:255:191:284:91", "FrostwindDunes:274:214:121:0", "GrimfrostHill:178:203:597:210", "Grombolash:217:239:483:33", "Gromgar:282:341:505:323", "IronSiegeworks:329:294:673:156", "IronwayStation:199:335:641:304", "Magnarok:213:278:609:33", "StonefangOutpost:251:191:306:281", "TheBoneSlag:256:210:290:192", "TheCracklingPlains:266:293:439:137", "Worgol:317:233:72:292",},
	["Gorgrond"] = {"BastionRise:324:161:283:507", "BeastWatch:166:161:383:371", "EasternRuin:210:193:525:260", "Evermorn:297:181:281:444", "Foundry:211:221:455:74", "FoundrySouth:217:180:454:183", "GronnCanyon:279:241:258:213", "HighlandPass:285:323:547:73", "HighPass:209:225:411:250", "IronDocks:315:180:350:0", "Mushrooms:253:198:444:323", "StonemaulArena:217:178:259:335", "StonemaulSouth:208:142:275:416", "Stripmine:250:232:312:77", "Tangleheart:262:221:451:372",},
	["NagrandDraenor"] = {"Ancestral:234:191:239:259", "BrokenPrecipice:305:227:256:12", "Elementals:286:274:588:0", "Grommashar:256:301:600:367", "Hallvalor:236:372:766:118", "Highmaul:471:437:0:0", "IronfistHarbor:236:242:283:354", "Lokrath:316:221:382:187", "Margoks:249:288:753:380", "Mushrooms:250:287:746:25", "Oshugun:262:266:366:323", "RingOfBlood:263:287:430:0", "RingOfTrials:354:315:523:159", "SunspringWatch:274:254:312:98", "Telaar:296:272:461:353",},
	["ShadowmoonValleyDR"] = {"AnguishFortress:309:264:140:160", "DarktideRoost:282:201:468:467", "Elodor:291:266:426:0", "Embaari:346:252:270:158", "Gloomshade:229:240:319:5", "Gulvar:260:309:26:0", "Karabor:393:318:537:150", "Shazgul:282:225:259:315", "ShimmeringMoor:288:261:453:306", "Socrethar:202:201:383:411", "Swisland:173:160:309:460",},
	["SpiresOfArak"] = {"BloodbladeRedoubt:209:154:334:210", "BloodmaneValley:229:246:410:350", "CenterRavenNest:188:190:444:255", "Clutchpop:217:224:533:382", "EastMushrooms:182:244:649:155", "EmptyGarrison:190:187:282:261", "HowlingCrag:382:274:459:0", "NwCorner:314:304:102:0", "SethekkHollow:238:295:520:127", "Skettis:371:174:289:0", "SoloSpireNorth:196:284:429:84", "SoloSpireSouth:169:178:374:276", "Southport:197:179:310:328", "Veilakraz:252:230:281:83", "Veilzekk:198:232:521:268", "VentureCove:226:193:465:475", "WrithingMire:229:213:197:198",},
	["Talador"] = {"Aruuna:389:234:597:178", "Auchindoun:309:262:338:356", "CenterIsles:252:280:546:228", "CourtOfSouls:307:229:150:264", "FortWrynn:292:235:567:42", "GordalFortress:423:290:548:378", "Gulrok:278:270:165:364", "Northgate:398:149:571:0", "OrunaiCoast:279:267:427:0", "SeEntrance:308:276:685:298", "Shattrath:406:367:173:22", "Telmor:497:157:207:511", "TombOfLights:326:212:352:271", "Tuurem:225:224:472:148", "Zangarra:287:277:713:35",},
	["TanaanJungle"] = {"DarkPortal:333:437:637:136", "DraeneiSW:174:208:81:367", "Fangrila:343:264:429:392", "FelForge:223:183:392:187", "HellfireCitadel:327:241:254:262", "IronFront:209:245:0:264", "IronHarbor:189:294:303:62", "Kiljaeden:365:276:392:23", "Kranak:338:254:54:94", "LionsWatch:270:208:465:313", "Marshlands:246:218:296:383", "Shanaar:248:314:170:354", "Volmar:238:229:501:171", "Zethgol:274:251:118:194",},

	-- Legion
	["Azsuna"] = {"Faronaar:330:265:166:202", "Felblaze:239:303:594:0", "Greenway:247:184:450:95", "IsleOfTheWatchers:321:267:281:401", "Llothienhighlands:351:245:219:69", "LostOrchard:315:185:257:0", "Narthalas:272:192:441:173", "OceanusCove:206:266:396:244", "RuinedSanctum:220:288:523:233",	"TempleLights:181:243:481:340",	"Zarkhenar:288:195:477:0",},
	["AszunaDungeonExterior"] = {"EyeOfAzshara:848:668:39:0"},
	["BrokenShore"] = ENGINE_LEGION_720 and {"BrokenValley:338:322:254:84", "DeadwoodLanding:182:245:220:260", "DeliverancePoint:387:314:312:302", "FelrageStrand:332:276:596:100", "SoulRuin:338:270:389:180", "TheLostTemple:308:244:632:169", "TheWeepingTerrace:276:213:350:13", "TombOfSargeras:312:301:500:0"} or {"BrokenShoreSouth:482:359:224:275", "TheBlackCity:478:328:257:95", "TheLostTemple:337:289:613:126", "TombOfSargeras:414:281:373:0"},
	["Highmountain"] = {"BloodHuntHighlands:297:250:307:75", "Feltotem:256:326:172:31", "FrostHoofWatch:186:213:391:408", "IronhornEnclave:288:258:452:410", "NightWatchersPerch:344:295:0:244", "PineRockBasin:217:148:323:249", "Riverbend:214:308:314:360", "RockawayShallows:207:302:469:45", "ShipwreckCove:283:170:331:0", "Skyhorn:311:229:357:179", "StonehoofWatch:341:328:494:236", "Sylvanfalls:445:326:0:342", "Thundertotem:244:199:332:302", "TrueshotLodge:172:204:249:236",},
	["Stormheim"] = {"AggrammarsVault:199:185:361:210", "BlackbeakOverlook:297:210:154:129", "Dreadwake:215:247:457:412", "Dreyrgrot:132:145:689:266", "Greywatch:173:163:648:339", "HallsOfValor:252:280:585:372",	"Haustvald:200:174:612:187", "Hrydshal:631:315:0:353", "MawOfNashal:509:251:17:0", "Morheim:150:180:741:313", "Nastrondir:241:194:345:95", "QatchmansRock:135:162:623:81",	"Runewood:194:214:592:226", "ShieldsRest:289:172:689:0", "SkoldAshil:177:169:506:345", "StormsReach:180:160:510:118", "TalonRest:291:208:316:282",	"TideskornHarbor:205:199:479:183", "Valdisdall:186:158:522:288", "WeepingBluffs:386:314:56:185",},
	["Suramar"] = {"Ambervale:222:311:132:179", "CrimsonThicket:327:381:492:0", "Falanaar:248:317:23:136", "FelsoulHold:289:363:183:305", "GrandPromenade:355:291:344:285", "Jandvik:419:538:583:0", "MoonguardStronghold:480:245:58:0", "MoonwhisperGulch:428:316:201:0", "RuinsOfEluneeth:221:224:264:226", "SuramarCity:470:337:390:331", "Telanor:387:372:327:0",},
	["Valsharah"] = {"Andutalah:241:240:587:250", "BlackrookHold:250:253:262:175", "BradensBrook:311:244:259:275", "DreamGrove:294:364:283:0",	"GloamingReef:239:301:136:274",	"GroveOfCenarius:171:150:457:351", "Lorlathil:177:156:467:413",	"MoonclawVale:254:281:549:380",	"Shalanir:326:360:419:0", "Smolderhide:341:188:324:480", "TempleOfElune:216:219:459:240", "Thastalah:218:168:342:416",},
	["ArgusCore"] = {"DefiledPath:626:385:293:0", "FelfireArmory:660:668:0:0", "Terminus:467:430:535:238",},
	["ArgusMacAree"] = {"Conservatory:313:353:498:111", "RuinsOfOronaar:265:310:278:284", "SeatOfTriumvirate:463:519:265:54", "Shadowguard:498:461:0:0", "Triumvirates:284:264:410:375", "UpperTerrace:701:323:0:0",},
	["ArgusSurface"] = {"AnnihilanPits:296:336:371:178", "KrokulHovel:307:304:428:364", "Nathraxas:835:422:167:0", "PetrifiedForest:445:379:557:289", "ShatteredFields:498:530:37:138",}
}

Module.SetUpAchievementLinks = function(self)
	-- Create editbox
	local aEB = CreateFrame("EditBox", nil, AchievementFrame)
	aEB:ClearAllPoints()
	aEB:SetPoint("BOTTOMRIGHT", -50, 1)
	aEB:SetHeight(16)
	aEB:SetFontObject("GameFontNormalSmall")
	aEB:SetBlinkSpeed(0)
	aEB:SetJustifyH("RIGHT")
	aEB:SetAutoFocus(false)
	aEB:EnableKeyboard(false)
	aEB:SetHitRectInsets(90, 0, 0, 0)
	aEB:SetScript("OnKeyDown", function() end)
	aEB:SetScript("OnMouseUp", function()
		if aEB:IsMouseOver() then
			aEB:HighlightText()
		else
			aEB:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	aEB.z = aEB:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	aEB.z:Hide()

	-- Store last link in case editbox is cleared
	local lastAchievementLink

	-- Function to set editbox value
	hooksecurefunc("AchievementFrameAchievements_SelectButton", function(self)
		local achievementID = self.id or nil
		if achievementID then
			-- Set editbox text
			aEB:SetText("https://" .. wowheadLoc .. "/achievement=" .. achievementID)
			lastAchievementLink = aEB:GetText()
			-- Set hidden fontstring then resize editbox to match
			aEB.z:SetText(aEB:GetText())
			aEB:SetWidth(aEB.z:GetStringWidth() + 90)
			-- Get achievement title for tooltip
			local achievementLink = GetAchievementLink(self.id)
			if achievementLink then
				aEB.tiptext = string_match(achievementLink, "%[(.-)%]")
			end
			-- Show the editbox
			aEB:Show()
		end
	end)

	local r,g,b = unpack(C.General.Title)
	local r2,g2,b2 = unpack(C.General.OffGreen)

	-- Create tooltip
	aEB:HookScript("OnEnter", function()
		aEB:HighlightText()
		aEB:SetFocus()
		if GameTooltip:IsForbidden() then 
			return 
		end 
		GameTooltip:SetOwner(aEB, "ANCHOR_TOP", 0, 10)
		GameTooltip:AddLine(aEB.tiptext, r,g,b)
		GameTooltip:AddLine(L["Press <CTRL+C> to copy."], r2,g2,b2)
		GameTooltip:Show()
	end)

	aEB:HookScript("OnLeave", function()
		-- Set link text again if it's changed since it was set
		if aEB:GetText() ~= lastAchievementLink then aEB:SetText(lastAchievementLink) end
		aEB:HighlightText(0, 0)
		aEB:ClearFocus()
		if GameTooltip:IsForbidden() then 
			return 
		end 
		GameTooltip:Hide()
	end)

	-- Hide editbox when achievement is deselected
	hooksecurefunc("AchievementFrameAchievements_ClearSelection", function(self) aEB:Hide()	end)
	hooksecurefunc("AchievementCategoryButton_OnClick", function(self) aEB:Hide() end)

end 

Module.SetUpEJLinks = function(self)

	-- Hide the title bar
	EncounterJournalTitleText:Hide()

	-- Create editbox
	local eEB = CreateFrame("EditBox", nil, EncounterJournal)
	eEB:ClearAllPoints()
	eEB:SetPoint("TOPLEFT", 70, -4)
	eEB:SetHeight(16)
	eEB:SetFontObject("GameFontNormal")
	eEB:SetBlinkSpeed(0)
	eEB:SetAutoFocus(false)
	eEB:EnableKeyboard(false)
	eEB:SetHitRectInsets(0, 90, 0, 0)
	eEB:SetScript("OnKeyDown", function() end)
	eEB:SetScript("OnMouseUp", function()
		if eEB:IsMouseOver() then
			eEB:HighlightText()
		else
			eEB:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	eEB.z = eEB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	eEB.z:Hide()

	-- Store last link in case user clears editbox
	local lastEJLink

	-- Function to set editbox value
	hooksecurefunc("EncounterJournal_DisplayInstance", function()
		local void, void, void, void, void, void, dungeonAreaMapID, link = EJ_GetInstanceInfo()
		local mapID, areaID = GetAreaMapInfo(dungeonAreaMapID)
		if areaID then
			-- Set editbox text
			eEB:SetText("https://" .. wowheadLoc .. "/zone=" .. areaID)
			lastEJLink = eEB:GetText()
			-- Set hidden fontstring then resize editbox to match
			eEB.z:SetText(eEB:GetText())
			eEB:SetWidth(eEB.z:GetStringWidth() + 90)
			-- Get achievement title for tooltip
			if link then
				eEB.tiptext = string_match(link, "%[(.-)%]") 
			end
			-- Show the editbox
			eEB:Show()
		end
	end)

	local r,g,b = unpack(C.General.Title)
	local r2,g2,b2 = unpack(C.General.OffGreen)

	-- Create tooltip
	eEB:HookScript("OnEnter", function()
		eEB:HighlightText()
		eEB:SetFocus()
		if GameTooltip:IsForbidden() then 
			return 
		end 
		GameTooltip:SetOwner(eEB, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:AddLine(eEB.tiptext, r,g,b)
		GameTooltip:AddLine(L["Press <CTRL+C> to copy."], r2,g2,b2)
		GameTooltip:Show()
	end)

	eEB:HookScript("OnLeave", function()
		-- Set link text again if it's changed since it was set
		if eEB:GetText() ~= lastEJLink then eEB:SetText(lastEJLink) end
		eEB:HighlightText(0, 0)
		eEB:ClearFocus()
		if GameTooltip:IsForbidden() then 
			return 
		end 
		GameTooltip:Hide()
	end)

	-- Hide editbox when instance list is shown
	hooksecurefunc("EncounterJournal_ListInstances", function()
		eEB:Hide()
	end)

end

Module.SetUpQuestLinks = function(self)

	-- Hide the title text
	WorldMapFrameTitleText:Hide()

	-- Create editbox
	local mEB = CreateFrame("EditBox", nil, WorldMapFrame.BorderFrame)
	mEB:ClearAllPoints()
	mEB:SetPoint("TOPLEFT", 100, -4)
	mEB:SetHeight(16)
	mEB:SetFontObject("GameFontNormal")
	mEB:SetBlinkSpeed(0)
	mEB:SetAutoFocus(false)
	mEB:EnableKeyboard(false)
	mEB:SetHitRectInsets(0, 90, 0, 0)
	mEB:SetScript("OnKeyDown", function() end)
	mEB:SetScript("OnMouseUp", function()
		if mEB:IsMouseOver() then
			mEB:HighlightText()
		else
			mEB:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	mEB.z = mEB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mEB.z:Hide()

	-- Function to set editbox value
	local function SetQuestInBox()
		local questID
		if QuestMapFrame.DetailsFrame:IsShown() then
			-- Get quest ID from currently showing quest in details panel
			questID = QuestMapFrame_GetDetailQuestID()
		--else
			-- Get quest ID from currently selected quest on world map
		--	questID = GetSuperTrackedQuestID()
		end
		if questID then
			-- Hide editbox if quest ID is invalid
			if questID == 0 then mEB:Hide() else mEB:Show() end
			-- Set editbox text
			mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)
			-- Set hidden fontstring then resize editbox to match
			mEB.z:SetText(mEB:GetText())
			mEB:SetWidth(mEB.z:GetStringWidth() + 90)
			-- Get quest title for tooltip
			local questLink = GetQuestLink(questID) or nil
			if questLink then
				local title = QuestInfoTitleHeader:GetText() or string_match(questLink, "%[(.-)%]")
				mEB.tiptext = title 
			else
				mEB.tiptext = ""
				if mEB:IsMouseOver() and WorldMapTooltip:IsShown() then WorldMapTooltip:Hide() end
			end
		end
	end

	-- Set URL when super tracked quest changes and on startup
	--mEB:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED")
	--mEB:SetScript("OnEvent", SetQuestInBox)
	--SetQuestInBox()

	-- Set URL when quest details frame is shown or hidden
	hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestInBox)
	hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestInBox)

	local r,g,b = unpack(C.General.Title)
	local r2,g2,b2 = unpack(C.General.OffGreen)

	-- Create tooltip
	mEB:HookScript("OnEnter", function()
		mEB:HighlightText()
		mEB:SetFocus()
		WorldMapTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
		WorldMapTooltip:AddLine(mEB.tiptext, r,g,b)
		WorldMapTooltip:AddLine(L["Press <CTRL+C> to copy."], r2,g2,b2)
		WorldMapTooltip:Show()
	end)

	mEB:HookScript("OnLeave", function()
		mEB:HighlightText(0, 0)
		mEB:ClearFocus()
		WorldMapTooltip:Hide()
		SetQuestInBox()
	end)

end 

Module.SetUpFogOfWar = function(self)
	local db = self.db

	-- Initialise counters
	local createdtex = 0
	local texcount = 0

	-- Create local texture table
	local MapTex = {}

	-- Create checkbox
	--local frame = CreateFrame("CheckButton", nil, WorldMapTitleButton, "OptionsCheckButtonTemplate")
	--frame:SetSize(23, 23)
	--frame:SetPoint("RIGHT", WorldMapTitleButton, "RIGHT", -10, -1)
	local frame = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
	frame:SetPoint("TOPRIGHT", -50, 0)
    frame:SetSize(23, 23)

	frame.f = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	frame.f:SetPoint("RIGHT", frame, "LEFT", -4, 0)
	frame.f:SetText(L["Reveal"])
	frame.f:Show()

	frame.UpdateTooltip = function(self) 
		if (GameTooltip:IsForbidden()) then 
			return 
		end 
		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = unpack(C.General.OffWhite)
		local r2, g2, b2 = unpack(C.General.Title)
	
		if db.revealHidden then 
			GameTooltip:AddLine(L["Hide Undiscovered Areas"], r2, g2, b2)
			GameTooltip:AddLine(L["Disable to hide areas|nyou have not yet discovered."], r, g, b)
		else 
			GameTooltip:AddLine(L["Reveal Hidden Areas"], r2, g2, b2)
			GameTooltip:AddLine(L["Enable to show hidden areas|nyou have not yet discovered."], r, g, b)
		end 
		
		GameTooltip:Show()
	end

	frame:HookScript("OnEnter", function(self) 
		if (GameTooltip:IsForbidden()) then 
			return 
		end 
		self:UpdateTooltip()
	end)

	frame:HookScript("OnLeave", function(self) 
		if (GameTooltip:IsForbidden()) then 
			return 
		end 
		GameTooltip:Hide()
	end)

	-- Handle clicks
	frame:SetScript("OnClick", function()
		if frame:GetChecked() == true then
			db.revealHidden = true
			if WorldMapFrame:IsShown() then
				local futuremap = GetCurrentMapAreaID()
				RefreshWorldMap()
				SetMapByID(futuremap)
			end
		else
			db.revealHidden = false
			if texcount > 0 then
				for i = 1, texcount do MapTex[i]:Hide() end
				texcount = 0
				if WorldMapFrame:IsShown() then
					RefreshWorldMap()
				end
			end
		end
		if (GameTooltip:IsForbidden()) then 
			return 
		end 
		if (GameTooltip:GetOwner() == self) then 
			self:UpdateTooltip()
		end
	end)

	-- Set checkbox state
	frame:SetScript("OnShow", function()
		if db.revealHidden == true then frame:SetChecked(true) else frame:SetChecked(false) end
	end)

	-- Update map
	hooksecurefunc("WorldMapFrame_Update", function()
		-- If map isn't shown, may as well not process anything
		if (not WorldMapFrame:IsShown()) or (db.revealHidden == false) then 
			return 
		end

		-- Hide textures from previous map
		if (texcount > 0) then
			for i = 1, texcount do
				MapTex[i]:Hide()
			end
			texcount = 0
		end

		-- Get current map
		local filename, _, _, _, sub = GetMapInfo()
		if sub then return end
		if (not filename) then 
			return 
		end

		local texpath = string_format([[Interface\WorldMap\%s\]], filename)
		local zone = zones[filename] or {}

		-- Create new textures for current map
		for _, num in next, zone do
			local tname, texwidth, texheight, offsetx, offsety = string_split(":", num)
			local texturename = texpath..tname
			local numtexwide, numtextall = math_ceil(texwidth / 256), math_ceil(texheight / 256)

			-- Work out how many textures are needed to fill the map
			local neededtex = texcount + numtextall * numtexwide

			-- Create the textures
			if (neededtex > createdtex) then
				for j = createdtex + 1, neededtex do
					MapTex[j] = WorldMapDetailFrame:CreateTexture(nil, "ARTWORK")
				end
				createdtex = neededtex
			end

			-- Process textures
			for j = 1, numtextall do
				local texturepxheight, texturefileheight
				if j < numtextall then
					texturepxheight = 256
					texturefileheight = 256
				else
					texturepxheight = texheight % 256
					if texturepxheight == 0 then
						texturepxheight = 256
					end
					texturefileheight = 16
					while texturefileheight < texturepxheight do
						texturefileheight = texturefileheight * 2
					end
				end

				for k = 1, numtexwide do
					if (texcount > createdtex) then 
						return 
					end
					texcount = texcount + 1
					local texture = MapTex[texcount]
					local texturepxwidth
					local texturefilewidth
					if k < numtexwide then
						texturepxwidth = 256
						texturefilewidth = 256
					else
						texturepxwidth = texwidth % 256
						if texturepxwidth == 0 then
							texturepxwidth = 256
						end
						texturefilewidth = 16
						while texturefilewidth < texturepxwidth do
							texturefilewidth = texturefilewidth * 2
						end
					end
					texture:SetWidth(texturepxwidth)
					texture:SetHeight(texturepxheight)
					texture:SetTexCoord(0, texturepxwidth / texturefilewidth, 0, texturepxheight / texturefileheight)
					texture:ClearAllPoints()
					texture:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", offsetx + (256 * (k - 1)), -(offsety + (256 * (j - 1))))
					texture:SetTexture(texturename..(((j - 1) * numtexwide) + k))
					texture:Show()
				end
			end
		end
	end)
end 

Module.SetUpWorldMap = function(self)
	if (not ENGINE_BFA) then 
		--WorldMapDetailFrame:SetAlpha(.75)
		
		local overlayTexture = WorldMapDetailFrame:CreateTexture(nil, "OVERLAY")
		overlayTexture:SetAllPoints()
		overlayTexture:SetColorTexture(.15,.1,.05,.35)

		hooksecurefunc("WorldMapFrame_Update", function() 
			local questMapID, isContinent = GetCurrentMapAreaID()
			if ((not questMapID) or (questMapID == -1)) and (not isContinent) then 
				overlayTexture:Hide()
			else 
				overlayTexture:Show()
			end 
		end)
	end 
end

local revealedFoggyAreas
Module.OnEvent = function(self, event, ...)
	if (event == "ADDON_LOADED") then 
		local arg = ...
		if (arg == "Blizzard_AchievementUI") then 
			self:SetUpAchievementLinks()
			self.addonCount = self.addonCount - 1
		elseif (arg == "Blizzard_EncounterJournal") then
			self:SetUpEJLinks()
			self.addonCount = self.addonCount - 1
		end
		if (self.addonCount == 0) then 
			self:UnregisterEvent("ADDON_LOADED", "OnEvent")
		end
	end
end

Module.OnInit = function(self)
	self.db = Module:GetConfig("WorldMap") 
end 

Module.OnEnable = function(self)
	-- Kill off the black background around the fullscreen worldmap, 
	-- so that we can see at least a little of what's going on.
	local BlizzardUI = self:GetHandler("BlizzardUI")
	BlizzardUI:GetElement("WorldMap"):Remove("BlackoutWorld")

	if ENGINE_LEGION then
		self:SetUpWorldMap()
		self:SetUpQuestLinks()
		self:SetUpFogOfWar()

		if IsAddOnLoaded("Blizzard_EncounterJournal") then
			self:SetUpEJLinks()
		else
			self.addonCount = (self.addonCount or 0) + 1
		end

		if IsAddOnLoaded("Blizzard_AchievementUI") then
			self:SetUpAchievementLinks()
		else
			self.addonCount = (self.addonCount or 0) + 1
		end

		if (self.addonCount) then 
			self:RegisterEvent("ADDON_LOADED", "OnEvent")
		end 
	end
end
