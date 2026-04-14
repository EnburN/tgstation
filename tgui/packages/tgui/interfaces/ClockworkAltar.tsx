import {
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  state: number;
  state_name: string;
  relics: number;
  relics_required: number;
  components: number;
  components_required: number;
  essence_cogs: number;
  essence_cogs_required: number;
  reforging_progress: number;
};

const ALTAR_STATE_REFORGING = 4;

export const ClockworkAltar = () => {
  return (
    <Window title="Altar of Reforging" width={380} height={320} theme="clockwork">
      <Window.Content>
        <AltarContent />
      </Window.Content>
    </Window>
  );
};

const AltarContent = () => {
  const { data } = useBackend<Data>();
  const {
    state,
    state_name,
    relics,
    relics_required,
    components,
    components_required,
    essence_cogs,
    essence_cogs_required,
    reforging_progress,
  } = data;

  return (
    <>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="State">{state_name}</LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Parts Progress">
        <LabeledList>
          <LabeledList.Item label="Relics">
            <ProgressBar
              value={relics}
              minValue={0}
              maxValue={relics_required}
              color={relics >= relics_required ? 'good' : 'average'}
            >
              {relics} / {relics_required}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Components">
            <ProgressBar
              value={components}
              minValue={0}
              maxValue={components_required}
              color={components >= components_required ? 'good' : 'average'}
            >
              {components} / {components_required}
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Essence Cogs">
            <ProgressBar
              value={essence_cogs}
              minValue={0}
              maxValue={essence_cogs_required}
              color={essence_cogs >= essence_cogs_required ? 'good' : 'average'}
            >
              {essence_cogs} / {essence_cogs_required}
            </ProgressBar>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {state === ALTAR_STATE_REFORGING && (
        <Section title="Reforging Ritual">
          <NoticeBox>The ritual is underway — protect the altar!</NoticeBox>
          <ProgressBar
            value={reforging_progress}
            minValue={0}
            maxValue={1}
            color="bad"
          >
            {Math.round(reforging_progress * 100)}% complete
          </ProgressBar>
        </Section>
      )}
    </>
  );
};
