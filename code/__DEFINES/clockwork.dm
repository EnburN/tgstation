// ---- Faction ----
#define FACTION_CLOCKWORK "clockwork"

// ---- Traits ----
#define TRAIT_HEALS_ON_CLOCKWORK_FLOOR "heals_on_clockwork_floor"
#define TRAIT_CLOCKWORK_SERVANT "clockwork_servant"

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

// ---- Ark Phases ----
#define ARK_PHASE_BUILD 1
#define ARK_PHASE_PREP 2
#define ARK_PHASE_DEFENSE 3
#define ARK_PHASE_ASSAULT 4
#define ARK_PHASE_CLEANUP 5
#define ARK_PHASE_COMPLETE 6

// ---- Ark Timings (in deciseconds) ----
/// Minimum build phase duration
#define ARK_BUILD_TIME_MIN (30 MINUTES)
/// Maximum build phase duration
#define ARK_BUILD_TIME_MAX (35 MINUTES)
/// Prep phase duration (grace period)
#define ARK_PREP_TIME (5 MINUTES)
/// Defense phase duration
#define ARK_DEFENSE_TIME (4 MINUTES)
/// Assault phase duration
#define ARK_ASSAULT_TIME (4 MINUTES)
/// Cleanup phase duration
#define ARK_CLEANUP_TIME (2 MINUTES)
/// Warning before prep phase starts
#define ARK_PREP_WARNING (30 SECONDS)

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
#define CLOCKWORK_RATVAR_KILLED 3

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

// ---- Lazy Template ----
#define LAZY_TEMPLATE_KEY_REEBE "reebe_city_of_cogs"

// ---- Global Vars ----
GLOBAL_VAR_INIT(clockwork_vitality, 0)
GLOBAL_DATUM(clockwork_ark, /obj/structure/clockwork_ark)
