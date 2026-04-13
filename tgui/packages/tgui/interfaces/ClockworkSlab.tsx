import { useState } from 'react';
import {
  Button,
  Dimmer,
  LabeledList,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

const TIER_NAMES: Record<number, string> = {
  1: 'Driver',
  2: 'Script',
  3: 'Application',
  4: 'Cyborg',
};

const TIER_COLORS: Record<number, string> = {
  1: '#BE8700',
  2: '#C0C0C0',
  3: '#FFD700',
  4: '#4169E1',
};

type Scripture = {
  type: string;
  name: string;
  desc: string;
  tier: number;
  power_cost: number;
  invocation_time: number;
  invokers_required: number;
  quickbind_icon: string;
  locked: boolean;
};

type ClockworkSlabData = {
  power: number;
  herald_active: boolean;
  script_unlocked: boolean;
  application_unlocked: boolean;
  quickbinds: string[];
  ark_phase: number;
  ark_time_remaining: number;
  servant_count: number;
  scriptures: Scripture[];
};

const ARK_PHASE_NAMES: Record<number, string> = {
  0: 'Inactive',
  1: 'Building',
  2: 'Preparation',
  3: 'Defense',
  4: 'Assault',
  5: 'Cleanup',
  6: 'Complete',
};

function formatTime(deciseconds: number): string {
  const totalSeconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

function formatPower(watts: number): string {
  if (watts >= 1000) {
    return `${(watts / 1000).toFixed(1)} kW`;
  }
  return `${Math.floor(watts)} W`;
}

export function ClockworkSlab() {
  const { act, data } = useBackend<ClockworkSlabData>();
  const [tab, setTab] = useState<'recital' | 'recollection'>('recital');

  const {
    power,
    herald_active,
    ark_phase,
    ark_time_remaining,
    servant_count,
    scriptures,
    quickbinds,
  } = data;

  return (
    <Window title="Clockwork Slab" theme="clockwork" width={600} height={500}>
      <Window.Content scrollable>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              {formatPower(power)}
            </LabeledList.Item>
            <LabeledList.Item label="Servants">
              {servant_count}
            </LabeledList.Item>
            <LabeledList.Item label="Ark">
              {ARK_PHASE_NAMES[ark_phase] || 'Unknown'}
              {ark_time_remaining > 0 && ` — ${formatTime(ark_time_remaining)}`}
            </LabeledList.Item>
            {!!herald_active && (
              <LabeledList.Item label="Herald" color="good">
                WAR DECLARED
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        <Tabs>
          <Tabs.Tab
            selected={tab === 'recital'}
            onClick={() => setTab('recital')}
          >
            Recital
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 'recollection'}
            onClick={() => setTab('recollection')}
          >
            Recollection
          </Tabs.Tab>
        </Tabs>

        {tab === 'recital' && (
          <RecitalTab scriptures={scriptures} quickbinds={quickbinds} />
        )}
        {tab === 'recollection' && <RecollectionTab />}
      </Window.Content>
    </Window>
  );
}

function RecitalTab(props: {
  scriptures: Scripture[];
  quickbinds: string[];
}) {
  const { act } = useBackend<ClockworkSlabData>();
  const { scriptures, quickbinds } = props;

  const tiers = [1, 2, 3, 4];

  return (
    <>
      {tiers.map((tier) => {
        const tierScriptures = scriptures.filter((s) => s.tier === tier);
        if (tierScriptures.length === 0) {
          return null;
        }
        const allLocked = tierScriptures.every((s) => s.locked);

        return (
          <Section
            key={tier}
            title={`${TIER_NAMES[tier]} Scripture`}
          >
            {allLocked && (
              <Dimmer>
                <b>LOCKED</b> — Requires more power or progress
              </Dimmer>
            )}
            {tierScriptures.map((scripture) => (
              <Section
                key={scripture.type}
                title={scripture.name}
                buttons={
                  <Stack>
                    <Stack.Item>
                      <Button
                        disabled={scripture.locked}
                        onClick={() =>
                          act('recite', {
                            scripture_type: scripture.type,
                          })
                        }
                      >
                        Recite
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        selected={quickbinds.includes(scripture.type)}
                        disabled={scripture.locked}
                        onClick={() =>
                          act('quickbind', {
                            scripture_type: scripture.type,
                          })
                        }
                      >
                        Quickbind
                      </Button>
                    </Stack.Item>
                  </Stack>
                }
              >
                <LabeledList>
                  <LabeledList.Item label="Cost">
                    {formatPower(scripture.power_cost)}
                  </LabeledList.Item>
                  <LabeledList.Item label="Time">
                    {scripture.invocation_time}s
                  </LabeledList.Item>
                  {scripture.invokers_required > 1 && (
                    <LabeledList.Item label="Invokers">
                      {scripture.invokers_required}
                    </LabeledList.Item>
                  )}
                </LabeledList>
                <p>{scripture.desc}</p>
              </Section>
            ))}
          </Section>
        );
      })}
    </>
  );
}

function RecollectionTab() {
  return (
    <Section title="Servant's Guide">
      <h3>Welcome, Servant of Ratvar</h3>
      <p>
        You have been chosen to free Ratvar, the Clockwork Justiciar, from his
        imprisonment. Your goal is to defend the Ark of the Clockwork Justiciar
        until it activates and summons your god.
      </p>
      <h3>The Clockwork Slab</h3>
      <p>
        This slab is your primary tool. Use the Recital tab to access scripture
        — your special abilities. You can quickbind up to 5 scripture for fast
        access via HUD buttons.
      </p>
      <h3>Power</h3>
      <p>
        All scripture costs power (measured in Watts). Power is shared among all
        servants. Generate power by inserting Integration Cogs into APCs, using
        Sigils of Transmission, or simply holding your slab.
      </p>
      <p>
        At <b>50 kW</b>, Script tier scripture unlocks. At <b>100 kW</b>,
        Application tier unlocks. Converting a crew member also unlocks
        Application tier.
      </p>
      <h3>The Ark</h3>
      <p>
        The Ark is in the northern chamber of Reebe. Defend it at all costs. If
        it is destroyed, your cult loses instantly. If it completes activation,
        Ratvar is summoned and you win.
      </p>
      <h3>Conversion</h3>
      <p>
        Stun targets with <b>Kindle</b>, restrain with{' '}
        <b>Hateful Manacles</b>, and drag them onto a{' '}
        <b>Sigil of Submission</b> with another servant nearby. After 8
        seconds, they become a servant.
      </p>
      <h3>The Hierophant Network</h3>
      <p>
        Use the Hierophant Network button on your HUD to communicate with all
        servants. Coordinate constantly — teamwork is essential.
      </p>
      <h3>Building</h3>
      <p>
        Use a <b>Replica Fabricator</b> to convert station structures to
        clockwork variants and produce brass sheets. Build walls, defenses, and
        traps to fortify Reebe against the coming crew assault.
      </p>
    </Section>
  );
}
