import React, { useState } from 'react';
import classNames from 'classnames';

const FOCUS_MODES = [
  {
    id: 'dnd',
    name: 'Do Not Disturb',
    icon: 'fa-moon',
    color: 'is-link',
    desc: 'Silence all notifications',
  },
  {
    id: 'sleep',
    name: 'Sleep',
    icon: 'fa-bed',
    color: 'is-info',
    desc: 'Wind down and limit apps',
  },
  {
    id: 'work',
    name: 'Work',
    icon: 'fa-briefcase',
    color: 'is-success',
    desc: 'Only work-related notifications',
  },
  {
    id: 'personal',
    name: 'Personal',
    icon: 'fa-heart',
    color: 'is-danger',
    desc: 'Only personal notifications',
  },
  {
    id: 'driving',
    name: 'Driving',
    icon: 'fa-car',
    color: 'is-warning',
    desc: 'Minimal distractions while driving',
  },
  {
    id: 'fitness',
    name: 'Fitness',
    icon: 'fa-dumbbell',
    color: 'is-primary',
    desc: 'Workout mode with health apps only',
  },
];

const SETTINGS_LIST = [
  {
    id: 'wifi',
    name: 'Wi-Fi',
    icon: 'fa-wifi',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'bluetooth',
    name: 'Bluetooth',
    icon: 'fa-bluetooth-b',
    iconBrand: true,
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'cellular',
    name: 'Cellular Data',
    icon: 'fa-signal',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'airplane',
    name: 'Airplane Mode',
    icon: 'fa-plane',
    type: 'toggle',
    defaultVal: false,
  },
  {
    id: 'hotspot',
    name: 'Personal Hotspot',
    icon: 'fa-tower-broadcast',
    type: 'toggle',
    defaultVal: false,
  },
  {
    id: 'location',
    name: 'Location Services',
    icon: 'fa-location-crosshairs',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'nfc',
    name: 'NFC',
    icon: 'fa-nfc-symbol',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'notifications',
    name: 'Notifications',
    icon: 'fa-bell',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'autorotate',
    name: 'Auto-Rotate',
    icon: 'fa-rotate',
    type: 'toggle',
    defaultVal: true,
  },
  {
    id: 'darkmode',
    name: 'Dark Mode',
    icon: 'fa-circle-half-stroke',
    type: 'toggle',
    defaultVal: true,
  },
];

export const SettingsTab = () => {
  const initToggles = {};

  SETTINGS_LIST.forEach(s => {
    initToggles[s.id] = s.defaultVal;
  });

  const [toggles, setToggles] = useState(initToggles);
  const [activeFocus, setActiveFocus] = useState(null);
  const [brightness, setBrightness] = useState(75);
  const [red, setRed] = useState(255);
  const [green, setGreen] = useState(255);
  const [blue, setBlue] = useState(255);
  const [volume, setVolume] = useState(60);
  const [textSize, setTextSize] = useState(16);
  const [nightShift, setNightShift] = useState(false);
  const [trueTone, setTrueTone] = useState(true);

  const handleToggle = id => {
    setToggles(prev => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const rgbPreview = `rgb(${red}, ${green}, ${blue})`;

  return (
    <div className="Settings">
      {/* Focus Modes */}
      <h2 className="Settings__heading">
        <i className="fa-solid fa-moon" /> Focus Modes
      </h2>
      <div className="Settings__focus-grid">
        {FOCUS_MODES.map(mode => (
          <button
            key={mode.id}
            type="button"
            className={classNames('Settings__focus-card', {
              'Settings__focus-card--active': activeFocus === mode.id,
            })}
            onClick={() =>
              setActiveFocus(activeFocus === mode.id ? null : mode.id)
            }
          >
            <i
              className={classNames(
                'fa-solid',
                mode.icon,
                'Settings__focus-icon',
              )}
            />
            <span className="Settings__focus-name">{mode.name}</span>
            <span className="Settings__focus-desc">{mode.desc}</span>
            {activeFocus === mode.id && (
              <span className="tag is-success is-light">Active</span>
            )}
          </button>
        ))}
      </div>

      {/* Quick Settings */}
      <h2 className="Settings__heading">
        <i className="fa-solid fa-sliders" /> Quick Settings
      </h2>
      <div className="Settings__toggles">
        {SETTINGS_LIST.map(setting => (
          <div key={setting.id} className="Settings__toggle-row">
            <div className="Settings__toggle-left">
              <i
                className={classNames(
                  setting.iconBrand ? 'fa-brands' : 'fa-solid',
                  setting.icon,
                )}
              />
              <span>{setting.name}</span>
            </div>
            <button
              type="button"
              className={classNames('Settings__switch', {
                'Settings__switch--on': toggles[setting.id],
              })}
              onClick={() => handleToggle(setting.id)}
              aria-label={`Toggle ${setting.name}`}
            >
              <span className="Settings__switch-knob" />
            </button>
          </div>
        ))}
      </div>

      {/* Display Settings */}
      <h2 className="Settings__heading">
        <i className="fa-solid fa-display" /> Display Settings
      </h2>
      <div className="Settings__display">
        <div className="Settings__slider-row">
          <label className="Settings__slider-label" htmlFor="brightness-slider">
            <i className="fa-solid fa-sun" /> Brightness
          </label>
          <input
            id="brightness-slider"
            type="range"
            min="0"
            max="100"
            value={brightness}
            onChange={e => setBrightness(Number(e.target.value))}
            className="Settings__slider"
          />
          <span className="Settings__slider-val">{brightness}%</span>
        </div>

        <div className="Settings__slider-row">
          <label className="Settings__slider-label" htmlFor="volume-slider">
            <i className="fa-solid fa-volume-high" /> Volume
          </label>
          <input
            id="volume-slider"
            type="range"
            min="0"
            max="100"
            value={volume}
            onChange={e => setVolume(Number(e.target.value))}
            className="Settings__slider"
          />
          <span className="Settings__slider-val">{volume}%</span>
        </div>

        <div className="Settings__slider-row">
          <label className="Settings__slider-label" htmlFor="text-size-slider">
            <i className="fa-solid fa-text-height" /> Text Size
          </label>
          <input
            id="text-size-slider"
            type="range"
            min="10"
            max="28"
            value={textSize}
            onChange={e => setTextSize(Number(e.target.value))}
            className="Settings__slider"
          />
          <span className="Settings__slider-val">{textSize}px</span>
        </div>

        <div className="Settings__toggle-row">
          <div className="Settings__toggle-left">
            <i className="fa-solid fa-temperature-half" />
            <span>Night Shift</span>
          </div>
          <button
            type="button"
            className={classNames('Settings__switch', {
              'Settings__switch--on': nightShift,
            })}
            onClick={() => setNightShift(!nightShift)}
            aria-label="Toggle Night Shift"
          >
            <span className="Settings__switch-knob" />
          </button>
        </div>

        <div className="Settings__toggle-row">
          <div className="Settings__toggle-left">
            <i className="fa-solid fa-eye" />
            <span>True Tone</span>
          </div>
          <button
            type="button"
            className={classNames('Settings__switch', {
              'Settings__switch--on': trueTone,
            })}
            onClick={() => setTrueTone(!trueTone)}
            aria-label="Toggle True Tone"
          >
            <span className="Settings__switch-knob" />
          </button>
        </div>
      </div>

      {/* RGB Color Controls */}
      <h2 className="Settings__heading">
        <i className="fa-solid fa-palette" /> Display Color (RGB)
      </h2>
      <div className="Settings__rgb">
        <div
          className="Settings__rgb-preview"
          style={{ background: rgbPreview }}
        >
          <span className="Settings__rgb-hex">{rgbPreview}</span>
        </div>

        <div className="Settings__rgb-sliders">
          <div className="Settings__rgb-row">
            <label
              className="Settings__rgb-label Settings__rgb-label--red"
              htmlFor="red-slider"
            >
              R
            </label>
            <input
              id="red-slider"
              type="range"
              min="0"
              max="255"
              value={red}
              onChange={e => setRed(Number(e.target.value))}
              className="Settings__slider Settings__slider--red"
            />
            <span className="Settings__slider-val">{red}</span>
          </div>

          <div className="Settings__rgb-row">
            <label
              className="Settings__rgb-label Settings__rgb-label--green"
              htmlFor="green-slider"
            >
              G
            </label>
            <input
              id="green-slider"
              type="range"
              min="0"
              max="255"
              value={green}
              onChange={e => setGreen(Number(e.target.value))}
              className="Settings__slider Settings__slider--green"
            />
            <span className="Settings__slider-val">{green}</span>
          </div>

          <div className="Settings__rgb-row">
            <label
              className="Settings__rgb-label Settings__rgb-label--blue"
              htmlFor="blue-slider"
            >
              B
            </label>
            <input
              id="blue-slider"
              type="range"
              min="0"
              max="255"
              value={blue}
              onChange={e => setBlue(Number(e.target.value))}
              className="Settings__slider Settings__slider--blue"
            />
            <span className="Settings__slider-val">{blue}</span>
          </div>
        </div>
      </div>
    </div>
  );
};
