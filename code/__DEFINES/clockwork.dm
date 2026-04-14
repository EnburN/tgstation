// ---- Faction ----
#define FACTION_CLOCKWORK "clockwork"

// ---- Traits ----
#define TRAIT_HEALS_ON_CLOCKWORK_FLOOR "heals_on_clockwork_floor"
#define TRAIT_CLOCKWORK_SERVANT "clockwork_servant"
/// Applied to a corpse blessed in the chapel, preventing it from being used for Vivisection excision.
#define TRAIT_BLESSED_CORPSE "blessed_corpse"

// ---- Macros ----
/// Checks if the given mob is a clockwork servant
#define IS_CLOCKWORK(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/clockwork))
/// Gets the clockwork antagonist datum if present
#define GET_CLOCKWORK(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/clockwork))
/// Checks if the mob is a servant or clockwork-faction mob
#define IS_CLOCKWORK_OR_CLOCKWORK_MOB(mob) ((IS_CLOCKWORK(mob)) || (mob.has_faction(FACTION_CLOCKWORK)))

// ---- Scripture Tiers ----
#define SCRIPTURE_DRIVER 1
#define SCRIPTURE_SCRIPT 2
#define SCRIPTURE_APPLICATION 3
#define SCRIPTURE_CYBORG 4

// ---- Scripture Tier Unlock Thresholds ----
/// Power threshold (in watts) to unlock Script tier
#define CLOCKWORK_SCRIPT_THRESHOLD 50000
/// Power threshold (in watts) to unlock Application tier
#define CLOCKWORK_APPLICATION_THRESHOLD 100000

// ---- Power Constants ----
/// Small passive power generation per slab per second (watts)
#define SLAB_PASSIVE_POWER 0.5
/// Power drained per second by an integration cog in an APC
#define INTEGRATION_COG_DRAIN_RATE 5
/// Cost to produce 5 brass sheets via replica fabricator
#define FABRICATOR_BRASS_COST 1250
/// Mania motor power consumption per second
#define MANIA_MOTOR_POWER_DRAIN 150
/// Obelisk broadcast cost
#define OBELISK_BROADCAST_COST 50
/// Obelisk gateway cost
#define OBELISK_GATEWAY_COST 2000

// ---- Herald's Beacon ----
/// Time window for war declaration vote
#define HERALD_VOTE_WINDOW (5 MINUTES)
/// Scripture speed multiplier when herald is active
#define HERALD_SCRIPTURE_SPEED_MULT 0.7
/// Power cost multiplier when herald is active
#define HERALD_POWER_COST_MULT 0.5
/// Flat damage reduction for clockwork golems
#define CLOCKWORK_GOLEM_DAMAGE_REDUCTION 0.15

// ---- Vitality ----
/// Vitality gained from destroying a non-servant corpse
#define VITALITY_CORPSE_BURST 100
/// Vitality cost to revive a dead servant
#define VITALITY_REVIVE_COST 150

// ---- Victory States ----
#define CLOCKWORK_VICTORY 1
#define CLOCKWORK_LOSS 2

// ---- Construction Values ----
#define CV_FLOOR 1
#define CV_WINDOW_HALF 1
#define CV_WINDOW_FULL 2
#define CV_TABLE 2
#define CV_WALL_GEAR 3
#define CV_WINDOOR 3
#define CV_WALL 5
#define CV_AIRLOCK 5
#define CV_WARDEN 15
#define CV_MOTOR 20
#define CV_OBELISK 20

// ---- Ocular Warden ----
/// Base damage per second
#define WARDEN_BASE_DAMAGE 15
/// Damage reduction per tile distance (percentage)
#define WARDEN_DISTANCE_REDUCTION 0.05
/// Damage reduction per dense object (percentage)
#define WARDEN_OBSTACLE_REDUCTION 0.10
/// Minimum spacing between wardens (tiles)
#define WARDEN_MIN_SPACING 3

// ---- Clockwork Floor Healing ----
/// Toxin damage healed per second on clockwork floors
#define CLOCKWORK_FLOOR_HEAL_RATE 3

// ---- Marauder Shield ----
/// Shield HP regeneration interval
#define MARAUDER_SHIELD_REGEN_TIME (20 SECONDS)

// ---- Vanguard ----
/// Vanguard buff duration
#define VANGUARD_DURATION (20 SECONDS)
/// Stun threshold before vanguard causes unconsciousness
#define VANGUARD_OVERLOAD_THRESHOLD (30 SECONDS)
/// Percentage of absorbed stuns applied on expiry
#define VANGUARD_REAPPLY_PERCENT 0.25

// ---- Spatial Gateway ----
/// Default gateway uses
#define GATEWAY_DEFAULT_USES 1
/// Default gateway duration
#define GATEWAY_DEFAULT_DURATION (4 SECONDS)
/// Obelisk gateway multiplier for uses and duration
#define GATEWAY_OBELISK_MULTIPLIER 2
/// Obelisk self-gateway uses
#define OBELISK_GATEWAY_USES 5
/// Obelisk self-gateway duration
#define OBELISK_GATEWAY_DURATION (10 SECONDS)

// ---- Altar Stage Thresholds ----
/// Cult population required to awaken the altar
#define ALTAR_AWAKEN_SERVANT_COUNT 6
/// Total parts deposited required to expose the altar
#define ALTAR_EXPOSE_PARTS_DEPOSITED 3

// ---- Part Counts ----
/// Number of relics required to summon Ratvar
#define RELICS_REQUIRED 4
/// Number of crafted components required to summon Ratvar
#define COMPONENTS_REQUIRED 3
/// Number of essence cogs required to summon Ratvar
#define ESSENCE_COGS_REQUIRED 2

// ---- Reforging Ritual ----
/// Minimum reforging duration
#define REFORGING_RITUAL_TIME_MIN (5 MINUTES)
/// Maximum reforging duration
#define REFORGING_RITUAL_TIME_MAX (8 MINUTES)
/// Roundend countdown after Ratvar manifests
#define RATVAR_ROUNDEND_DELAY (30 SECONDS)

// ---- Crafting Timings ----
/// Time to craft a single component at the workbench
#define COMPONENT_CRAFT_TIME (60 SECONDS)
/// Time for surgical excision at vivisection slab
#define ESSENCE_EXCISION_TIME (60 SECONDS)
/// Time to identify a relic by clockwork slab
#define RELIC_IDENTIFICATION_TIME (5 SECONDS)
/// Cooldown for the slab's locate-relic ability
#define RELIC_LOCATE_COOLDOWN (2 MINUTES)
/// Time to deposit a part at the altar (servants)
#define PART_DEPOSIT_TIME (3 SECONDS)

// ---- Eminence ----
/// Vote window when a candidate uses an Eminence Spire
#define EMINENCE_VOTE_WINDOW (60 SECONDS)
/// Spire HP
#define EMINENCE_SPIRE_HP 100

// ---- Altar Materialization States ----
#define ALTAR_STATE_DORMANT 1
#define ALTAR_STATE_AWAKENED 2
#define ALTAR_STATE_EXPOSED 3
#define ALTAR_STATE_REFORGING 4
#define ALTAR_STATE_COMPLETE 5

// ---- Altar HP ----
#define ALTAR_MAX_INTEGRITY 600

// ---- Cogscarab ----
/// Dim Gears stealth cooldown
#define COGSCARAB_DIM_GEARS_COOLDOWN (30 SECONDS)
/// Dim Gears duration
#define COGSCARAB_DIM_GEARS_DURATION (15 SECONDS)
/// Combat buff range from altar in tiles
#define COGSCARAB_DEFENSE_BUFF_RANGE 7

// ---- Vivisection Slab HP ----
#define VIVISECTION_SLAB_HP 150

// ---- Forge Workbench HP ----
#define FORGE_WORKBENCH_HP 120

// ---- Globals ----
GLOBAL_DATUM(clockwork_altar, /obj/structure/clockwork_altar)
GLOBAL_LIST_EMPTY(eminence_spires)

// ---- Global Vars ----
GLOBAL_VAR_INIT(clockwork_vitality, 0)
