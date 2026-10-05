import { copyFileSync, existsSync, mkdirSync, readFileSync, renameSync, statSync, writeFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join } from 'node:path';
import {
  complexModifications, ifInputSource, map, rule, simpleModifications,
  type DeviceIdentifier, type FromKeyCode, type KarabinerProfile,
  type SimpleManipulator, type ToKeyCode,
} from 'karabiner.ts';

const profileName = 'Default profile';

function remapKeys(pairs: [FromKeyCode, ToKeyCode][]): SimpleManipulator[] {
  return simpleModifications(pairs.map(([from, to]) => map(from).to(to)));
}

// Keep device-specific mappings as simple modifications: their ordering relative
// to complex modifications affects the right Option → Command input toggle.
const devices = [
  {
    identifiers: { is_keyboard: true, product_id: 21034, vendor_id: 1155 },
    simple_modifications: remapKeys([
      ['backslash', 'delete_or_backspace'],
      ['delete_forward', 'up_arrow'],
      ['delete_or_backspace', 'backslash'],
      ['right_option', 'right_command'],
      ['up_arrow', 'right_shift'],
    ]),
  },
  {
    identifiers: { is_keyboard: true, product_id: 521, vendor_id: 1241 },
    simple_modifications: remapKeys([
      ['backslash', 'delete_or_backspace'],
      ['delete_or_backspace', 'backslash'],
      ['left_option', 'left_command'],
      ['left_command', 'left_option'],
      ['right_option', 'right_command'],
      ['right_command', 'right_option'],
    ]),
  },
  {
    identifiers: { is_keyboard: true, product_id: 591, vendor_id: 1452 },
    simple_modifications: remapKeys([
      ['home', 'vk_none'], ['end', 'vk_none'],
      ['page_down', 'vk_none'], ['page_up', 'vk_none'],
    ]),
  },
];

const profile: KarabinerProfile & {
  devices: typeof devices;
  virtual_hid_keyboard: { keyboard_type_v2: 'ansi' };
} = {
  name: profileName,
  selected: true,
  devices,
  simple_modifications: remapKeys([['caps_lock', 'left_control']]),
  virtual_hid_keyboard: { keyboard_type_v2: 'ansi' },
  complex_modifications: complexModifications([
    rule('Tap command to switch input source').manipulators(
      (['left_command', 'right_command'] as const).flatMap((command) =>
        ([true, false] as const).map((isJapanese) =>
          map(command)
            .to({ key_code: command, lazy: true })
            .toIfAlone(isJapanese ? 'japanese_eisuu' : 'japanese_kana')
            .toIfHeldDown(command)
            .condition(isJapanese
              ? ifInputSource({ language: 'ja' })
              : ifInputSource({ language: 'ja' }).unless())
            .parameters({
              'basic.to_if_alone_timeout_milliseconds': 100,
              'basic.to_if_held_down_threshold_milliseconds': 100,
            }),
        ),
      ),
    ),
  ], {
    'basic.to_if_alone_timeout_milliseconds': 1000,
    'basic.to_if_held_down_threshold_milliseconds': 500,
    'basic.to_delayed_action_delay_milliseconds': 500,
    'basic.simultaneous_threshold_milliseconds': 50,
    'mouse_motion_to_scroll.speed': 100,
  }),
};

type ExistingDevice = { identifiers: DeviceIdentifier; [key: string]: unknown };
type ExistingProfile = {
  name: string;
  selected?: boolean;
  devices?: ExistingDevice[];
  virtual_hid_keyboard?: Record<string, unknown>;
  [key: string]: unknown;
};
type Config = { profiles: ExistingProfile[]; [key: string]: unknown };

const apply = process.argv.includes('--apply');
if (process.argv.slice(2).some((argument) => argument !== '--apply')) {
  throw new Error('Usage: node index.ts [--apply]');
}
const target = apply
  ? process.env.KARABINER_CONFIG_PATH ?? join(
      process.env.XDG_CONFIG_HOME ?? join(homedir(), '.config'), 'karabiner', 'karabiner.json',
    )
  : new URL('./dist/karabiner.json', import.meta.url).pathname;

let config: Config = { profiles: [profile] };
if (apply && existsSync(target)) {
  config = JSON.parse(readFileSync(target, 'utf8')) as Config;
  if (!Array.isArray(config.profiles)) throw new Error('Invalid Karabiner profiles');
  const current = config.profiles.find((item) => item.name === profileName);
  if (current) {
    const mergedDevices = [...(current.devices ?? [])];
    for (const device of devices) {
      const index = mergedDevices.findIndex((item) =>
        item.identifiers.vendor_id === device.identifiers.vendor_id &&
        item.identifiers.product_id === device.identifiers.product_id &&
        item.identifiers.is_keyboard === device.identifiers.is_keyboard &&
        !item.identifiers.is_pointing_device && !item.identifiers.device_address,
      );
      if (index < 0) mergedDevices.push(device);
      else mergedDevices[index] = { ...mergedDevices[index], ...device };
    }
    Object.assign(current, {
      simple_modifications: profile.simple_modifications,
      complex_modifications: {
        ...(current.complex_modifications as Record<string, unknown> | undefined),
        ...profile.complex_modifications,
      },
      devices: mergedDevices,
      virtual_hid_keyboard: { ...current.virtual_hid_keyboard, ...profile.virtual_hid_keyboard },
    });
  } else {
    config.profiles.push({ ...profile, selected: !config.profiles.some((item) => item.selected) });
  }
}

const json = JSON.stringify(config, null, 2) + '\n';
mkdirSync(dirname(target), { recursive: true });
if (apply && existsSync(target)) {
  const backup = `${target}.backup-${Date.now()}`;
  copyFileSync(target, backup);
  console.log(`Backup: ${backup}`);
}
const mode = existsSync(target) ? statSync(target).mode & 0o777 : 0o600;
const temporary = `${target}.${process.pid}.tmp`;
writeFileSync(temporary, json, { mode, flag: 'wx' });
renameSync(temporary, target);
console.log(`${apply ? 'Applied' : 'Generated'}: ${target}`);
