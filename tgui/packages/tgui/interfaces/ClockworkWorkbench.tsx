import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Material = {
  type: string;
  name: string;
  amount: number;
};

type Recipe = {
  type: string;
  name: string;
  desc: string;
  power_cost: number;
  inputs: string;
  can_craft: boolean;
};

type Data = {
  crafting: boolean;
  recipe_name: string | null;
  time_remaining: number;
  power: number;
  reserves: Material[];
  recipes: Recipe[];
};

export const ClockworkWorkbench = () => {
  return (
    <Window title="Forge Workbench" width={480} height={600} theme="clockwork">
      <Window.Content scrollable>
        <WorkbenchContent />
      </Window.Content>
    </Window>
  );
};

const WorkbenchContent = () => {
  const { act, data } = useBackend<Data>();
  const { crafting, recipe_name, time_remaining, power, reserves, recipes } =
    data;

  return (
    <>
      <Section title="Power Reserve">
        <LabeledList>
          <LabeledList.Item label="Available Power">
            {power}W
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section title="Stored Materials">
        {reserves.length === 0 ? (
          <NoticeBox>No materials stored. Feed stacks or reagents into the workbench.</NoticeBox>
        ) : (
          <LabeledList>
            {reserves.map((mat) => (
              <LabeledList.Item key={mat.type} label={mat.name}>
                {mat.amount}
              </LabeledList.Item>
            ))}
          </LabeledList>
        )}
      </Section>
      {crafting && (
        <Section title="Active Crafting">
          <LabeledList>
            <LabeledList.Item label="Recipe">
              {recipe_name}
            </LabeledList.Item>
            <LabeledList.Item label="Time Remaining">
              <ProgressBar
                value={time_remaining > 0 ? time_remaining : 0}
                minValue={0}
                maxValue={60}
                color="good"
              >
                {time_remaining}s remaining
              </ProgressBar>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
      <Section title="Recipes">
        {recipes.map((recipe) => (
          <Section
            key={recipe.type}
            title={recipe.name}
            buttons={
              <Button
                icon="hammer"
                disabled={!recipe.can_craft || crafting}
                color={recipe.can_craft && !crafting ? 'caution' : 'default'}
                onClick={() => act('craft', { recipe_type: recipe.type })}
              >
                Forge
              </Button>
            }
          >
            <Box color="label" mb={1}>
              {recipe.desc}
            </Box>
            <LabeledList>
              <LabeledList.Item label="Power Cost">
                {recipe.power_cost}W
              </LabeledList.Item>
              <LabeledList.Item label="Materials">
                {recipe.inputs}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Section>
    </>
  );
};
