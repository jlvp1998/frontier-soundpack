-- Which file plays for each game sound. Paths are inside the sounds folder.
-- A list of files means one is picked at random each time.
-- To change a sound, just change the path here and reload the world.

spmap = {
  -- general
  ["general/step"] = {"general/footsteps/generic/l1.wav", "general/footsteps/generic/l2.wav", "general/footsteps/generic/l3.wav", "general/footsteps/generic/m1.wav", "general/footsteps/generic/m2.wav", "general/footsteps/generic/m3.wav"},
  ["general/rankup"] = "general/level/level.wav",
  ["general/notify"] = "general/Misc/notify.wav",
  ["general/support"] = "general/comms/petition.wav",

  -- talking
  ["social/say"] = "general/Misc/say.wav",
  ["social/ask"] = "general/Misc/say.wav",
  ["social/exclaim"] = "general/Misc/say.wav",

  -- starships
  ["ship/launch"] = {"ships/Movement/launch1.wav", "ships/Movement/launch2.wav", "ships/Movement/launch3.wav", "ships/Movement/launch4.wav", "ships/Movement/launch5.wav"},
  ["ship/launch_outside"] = "ships/misc/launch.wav",
  ["ship/land"] = {"ships/Movement/landing1.wav", "ships/Movement/landing2.wav", "ships/Movement/landing3.wav", "ships/Movement/landing4.wav"},
  ["ship/land_outside"] = {"ships/misc/otherlanding1.wav", "ships/misc/otherlanding2.wav"},
  ["ship/engine"] = "ships/Movement/acceleration.wav",
  ["ship/stop"] = "ships/Movement/deceleration.wav",
  ["ship/arrive"] = "general/Misc/arriveddestination.wav",
  ["ship/alarm"] = "ships/FlightControl/fcflyintostar.wav",
  ["ship/course"] = "ships/misc/courseset.wav",
  ["ship/sweep"] = "ships/computer/display1.wav",
  ["ship/mine"] = "ships/comets/mininglaser.wav",
  ["ship/salvage"] = "ships/salvaging/dronelaunch.wav",
  ["ship/harvest"] = "activities/nebula/rodextend.wav",
  ["ship/collect"] = "ships/comets/getstuff.wav",
  ["ship/airlock"] = "ships/misc/airlock.wav",
  ["ship/warp"] = "ships/Movement/warp.ogg",
  ["ship/warpengine"] = "ships/Movement/warpacceleration.ogg",
  ["ship/warpend"] = "ships/Movement/warpend.ogg",
  ["ship/quantum"] = "ships/Movement/quantimestart.ogg",
  ["ship/quantumengine"] = "ships/Movement/quantimeengine.ogg",
  ["ship/quantumend"] = "ships/Movement/quantimeend.ogg",
  ["ship/sub"] = "ships/Movement/wormhole.ogg",
  ["ship/refuel"] = "ships/misc/fuellinereplace.ogg",

  -- space combat
  ["combat/alert"] = "ships/Combat/redalert.ogg",
  ["combat/aim"] = "ships/computer/keypress1.ogg",
  ["combat/lock"] = "ships/Combat/targeted.ogg",
  ["combat/laser"] = "ships/Combat/laser.ogg",
  ["combat/cannon"] = "ships/Combat/pulsecannon.ogg",
  ["combat/miss"] = "ships/Combat/energydeflect.ogg",
  ["combat/hit"] = {"ships/Combat/youhit1.ogg", "ships/Combat/youhit2.ogg", "ships/Combat/youhit3.ogg", "ships/Combat/youhit4.ogg", "ships/Combat/youhit5.ogg", "ships/Combat/youhit6.ogg"},
  ["combat/hitus"] = {"ships/Combat/otherhit1.ogg", "ships/Combat/otherhit2.ogg", "ships/Combat/otherhit3.ogg"},
  ["combat/explode"] = {"ships/combat/otherdestroyed1.ogg", "ships/combat/otherdestroyed2.ogg", "ships/combat/otherdestroyed3.ogg", "ships/combat/otherdestroyed4.ogg", "ships/combat/otherdestroyed5.ogg", "ships/combat/otherdestroyed6.ogg", "ships/combat/otherdestroyed7.ogg"},
  ["combat/towed"] = "ships/Combat/shieldsfail.ogg",
  ["combat/repairloop"] = "vehicle/repairloop.ogg",  -- loops while crews repair the hull in space
  ["combat/repair"] = "vehicle/repairstop.ogg",

  -- firefighting
  ["fire/dispatch"] = "general/comms/dispatch.ogg",
  ["fire/start"] = "general/combat/fire.ogg",
  ["fire/siren"] = {"vehicle/siren1.ogg", "vehicle/siren2.ogg"},
  ["fire/sirenin"] = "general/gmc/sirenin.ogg",   -- loops inside the fire truck while the siren is on
  ["fire/sirenout"] = "general/gmc/sirenout.ogg", -- heard outside
  ["fire/sirenoff"] = "vehicle/sirenoff.ogg",
  ["fire/spray"] = "vehicle/hose.ogg",
  ["fire/out"] = "general/combat/armor/water.ogg",
  ["fire/heat"] = "general/combat/armor/fire.ogg",
  ["fire/refill"] = "ships/misc/fuellinereplace.ogg",

  -- engines (crank / uncrank). Inside the vehicle hears car/start, outside hears car/start_out.
  ["car/start"] = "general/cars/start.ogg",
  ["car/start_out"] = "general/cars/start_out.ogg",
  ["car/stop"] = "general/cars/shutdown.ogg",
  ["car/stop_out"] = "general/cars/shutdown_out.ogg",
  -- orbit cleaning (trawl / reel)
  ["orbit/net"] = "ships/misc/cargonetlower.ogg",
  ["orbit/haul"] = "ships/misc/netslam.ogg",
  ["orbit/stop"] = "activities/trash collection/orbitgearretract.ogg",
  -- void rats
  ["rats/appear"] = "ships/ratika/ratappear.ogg",
  ["rats/alarm"] = "ships/ratika/ratikadetected.ogg",
  ["rats/sniff"] = "ships/ratika/sniff.ogg",
  ["rats/squeak"] = "ships/ratika/noise.ogg",
  ["rats/scurry"] = "ships/ratika/claw.ogg",
  ["rats/gnaw"] = {"ships/ratika/bite.ogg", "ships/ratika/sparks.ogg"},
  ["rats/build"] = {"ships/ratika/build1.ogg", "ships/ratika/build2.ogg", "ships/ratika/build3.ogg", "ships/ratika/build4.ogg", "ships/ratika/build5.ogg", "ships/ratika/build6.ogg", "ships/ratika/build7.ogg", "ships/ratika/build8.ogg", "ships/ratika/build9.ogg"},
  ["rats/hit"] = "ships/ratika/hit.ogg",
  ["rats/smash"] = "ships/ratika/break.ogg",
  ["rats/install"] = "ships/ratika/powerup.ogg",
  ["rats/spray"] = "ships/ratika/spray.ogg",
  ["rats/dead"] = "ships/ratika/dead.ogg",
  ["rats/empty"] = "ships/ratika/emptyspray.ogg",
  -- home planets
  ["amb/maren_city"] = "ambiances/beach.ogg",
  ["amb/maren_docks"] = "ambiances/river2.ogg",
  ["amb/corvath_town"] = "ambiances/mountain.ogg",
  ["amb/corvath_mine"] = "ambiances/old_mining tunnel.ogg",
  ["amb/ilios_city"] = "ambiances/lobby.ogg",
  ["amb/ilios_under"] = "ambiances/hallway.ogg",
  ["amb/teshra_town"] = "ambiances/path.ogg",
  ["amb/teshra_dunes"] = "ambiances/road.ogg",
  ["amb/sylvane_village"] = "ambiances/garden.ogg",
  ["amb/sylvane_jungle"] = "ambiances/jungle.ogg",
  -- menus (sound settings and other numbered menus)
  ["menu/open"] = "general/misc/prompt1.ogg",
  ["menu/prompt"] = "general/misc/prompt2.ogg",
  ["menu/select"] = "general/misc/boop.ogg",
  ["menu/invalid"] = "general/misc/commandwrong.ogg",
  ["menu/cancel"] = "general/misc/abort.ogg",
  ["menu/close"] = "general/misc/spsave.ogg",
  ["menu/up"] = "general/misc/volumeup.ogg",
  ["menu/down"] = "general/misc/volumedown.ogg",
  -- government halls
  ["amb/gov_hall"] = "ambiances/hall.ogg",
  ["amb/gov_reg"] = "ambiances/lobby.ogg",
  ["amb/gov_office"] = "ambiances/office.ogg",
  -- teleporters
  ["amb/teleporter"] = "ambiances/teleport.ogg",
  ["teleport/charge"] = "general/misc/teleport1.ogg",
  ["teleport/out"] = "general/misc/teleport2.ogg",
  ["teleport/in"] = "general/misc/teleport3.ogg",
  -- vehicle storage (store / retrieve at landing pads)
  ["vehicle/store"] = "vehicle/vehiclerelocate.ogg",
  -- trash truck
  ["truck/door"] = "vehicle/opendoor.wav",
  ["truck/drive"] = "general/misc/speedwalkon.ogg",
  ["truck/stop"] = "general/misc/speedwalkoff.ogg",
  ["truck/arm"] = "activities/Trash collection/scoop.wav",
  ["truck/load"] = "vehicle/dump.wav",
  ["truck/machine"] = "activities/Trash collection/grind.wav",
  ["truck/transfer"] = "vehicle/transfer.wav",
  ["truck/lock"] = "vehicle/vehiclelock.wav",
  ["truck/unlock"] = "vehicle/chirptwice.wav",

  -- shops
  ["shop/buy"] = "general/Misc/cash-register-antiq-bell-op.wav",
  ["shop/sell"] = "general/Misc/cashcheck.wav",
  ["shop/upgrade"] = "ships/misc/installing.wav",
  ["shop/vehicle"] = "vehicle/chirponce.wav",

  -- ground jobs
  ["jobs/collect"] = "activities/Trash collection/scoop.wav",
  ["jobs/collect_done"] = "activities/Trash collection/crunch.wav",
  ["jobs/mine"] = {"activities/hand mining/dig1.wav", "activities/hand mining/dig2.wav"},
  ["jobs/mine_done"] = "activities/hand mining/find.wav",
  ["jobs/fish"] = "activities/fishing/fishcast.wav",
  ["jobs/fish_done"] = "activities/fishing/fishcatch.wav",
  ["jobs/hunt"] = "activities/hunt/run.wav",
  ["jobs/hunt_done"] = "activities/hunt/done.wav",
  ["jobs/chop"] = "activities/hunt/chop.ogg",
  ["jobs/chop_done"] = "activities/hunt/tree.ogg",
  ["jobs/fail"] = "activities/fishing/misscatch.wav",

  -- volcano harvesting
  ["volcano/start"] = "activities/volcanoHarvesting/drill.wav",
  ["volcano/scoop"] = "activities/VolcanoMining/bubble.wav",
  ["volcano/drift"] = "activities/volcanoHarvesting/unstable.wav",
  ["volcano/shift"] = "activities/volcanoHarvesting/center.wav",
  ["volcano/rockfall"] = "activities/volcanoHarvesting/rockfall.wav",
  ["volcano/rumble"] = {"general/comms/rumble1.wav", "general/comms/rumble2.wav", "general/comms/rumble3.wav"},
  ["volcano/erupt"] = "activities/hand mining/erupt.wav",
  ["volcano/broken"] = "ships/misc/nopower.wav",
  ["volcano/stop"] = "activities/volcanoHarvesting/release.wav",
  ["volcano/transfer"] = "activities/volcanoharvesting/volcanotransferbegin.ogg",
  ["volcano/transferdone"] = "activities/volcanoharvesting/volcanotransferend.ogg",
  ["volcano/repair"] = "vehicle/beginrepair.wav",
  ["volcano/repaired"] = "vehicle/repairstop.wav",

  -- radio
  ["radio/channel"] = "general/comms/radio.wav",
  ["radio/home"] = "general/comms/origins.ogg",
  ["radio/flight"] = "ships/FlightControl/fc.wav",
  ["radio/receive"] = "general/comms/privcom.wav",
  ["radio/send"] = "general/comms/shortwave.wav",
  ["radio/request"] = "general/comms/linkrequest.wav",

  -- phone
  ["phone/dial"] = "general/comms/phonering.wav",
  ["phone/ring"] = "general/telephone/ring.wav",
  ["phone/missed"] = "general/telephone/error.wav",
  ["phone/answer"] = "general/comms/pickup.wav",
  ["phone/hangup"] = "general/telephone/click.wav",
  ["phone/talk"] = "general/telephone/talk.wav",
  ["phone/send"] = "general/comms/mailsent.wav",
  ["phone/text"] = "general/comms/textmessage.wav",
  ["phone/voicemail"] = "general/telephone/message.wav",
  ["phone/beep"] = "ships/misc/beep1.wav",

  -- food and vending
  ["food/eat"] = "general/Food and drink/eatfood.wav",
  ["food/drink"] = "general/Food and drink/gulpliquid.wav",
  ["vending/buy"] = "general/Misc/vending machine.wav",
  ["vending/coins"] = "general/Misc/credits1.wav",

  -- background sounds (loop)
  ["amb/academy"] = "ambiances/hall.wav",
  ["amb/docking_bay"] = "ships/Rooms/dockingbay.wav",
  ["amb/lower_decks"] = "ambiances/trash.wav",
  ["amb/station_shop"] = "ambiances/store.wav",
  ["amb/vehicle_yard"] = "ambiances/garage.wav",
  ["amb/recycling_plant"] = "ambiances/crushary.wav",
  ["amb/truck"] = "ambiances/transportvehicle.wav",   -- fire truck engine running
  ["amb/trashtruck"] = "ambiances/trash.ogg",          -- trash truck engine running
  ["amb/harvester"] = "ambiances/volcano.ogg",         -- volcano harvester engine running
  ["amb/vehicle_off"] = "ambiances/vehiclenopower.ogg",  -- any vehicle with the engine off
  ["amb/ship_bridge"] = "ships/Rooms/bridge1.wav",
  ["amb/ship_corridor"] = "ships/Rooms/corridor.wav",
  ["amb/ship_engine"] = "ships/Rooms/engineering.wav",
  ["amb/ship_airlock"] = "ships/Rooms/airlock.wav",
  ["amb/landing_pad"] = "ambiances/landingpad.wav",
  ["amb/veyra_pad"] = "ambiances/landingpad.wav",
  ["amb/veyra_settlement"] = "ambiances/plaza.wav",
  ["amb/veyra_store"] = "ambiances/store.wav",
  ["amb/shop"] = "ambiances/shopping.wav",
  ["amb/quarry"] = "ambiances/mining tunnel.wav",
  ["amb/lake"] = "ambiances/lake.wav",
  ["amb/wilds"] = "ambiances/woods.wav",
  ["amb/foothills"] = "ambiances/mountain.wav",
  ["amb/outpost"] = "ambiances/office.wav",
  ["amb/lava_tube"] = "ambiances/volcano.wav",
}
