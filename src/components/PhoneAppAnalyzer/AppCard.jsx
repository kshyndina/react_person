import React from 'react';
import classNames from 'classnames';

const getRiskBadge = riskLevel => {
  const classes = classNames('tag', {
    'is-success': riskLevel === 'low',
    'is-warning': riskLevel === 'medium',
    'is-danger': riskLevel === 'high',
  });

  return <span className={classes}>{riskLevel.toUpperCase()}</span>;
};

const getPermissionIcon = permission => {
  const icons = {
    Camera: 'fa-camera',
    Microphone: 'fa-microphone',
    Location: 'fa-location-dot',
    Contacts: 'fa-address-book',
    Storage: 'fa-hard-drive',
    Clipboard: 'fa-clipboard',
    Phone: 'fa-phone',
    SMS: 'fa-message',
    Network: 'fa-wifi',
    Biometrics: 'fa-fingerprint',
    'Health Data': 'fa-heart-pulse',
    Sensors: 'fa-gauge',
  };

  return icons[permission] || 'fa-circle';
};

export const AppCard = ({ app, isExpanded, onToggle }) => (
  <div
    className={classNames('AppCard', {
      'AppCard--expanded': isExpanded,
      'AppCard--high-risk': app.riskLevel === 'high',
    })}
  >
    <div
      className="AppCard__header"
      onClick={onToggle}
      role="button"
      tabIndex={0}
      onKeyDown={e => e.key === 'Enter' && onToggle()}
    >
      <div className="AppCard__icon-wrapper">
        <i
          className={classNames(
            app.iconBrand ? 'fa-brands' : 'fa-solid',
            app.icon,
            'AppCard__icon',
          )}
        />
      </div>

      <div className="AppCard__info">
        <h3 className="AppCard__name">{app.name}</h3>
        <span className="AppCard__category tag is-light is-info">
          {app.category}
        </span>
      </div>

      <div className="AppCard__quick-stats">
        {getRiskBadge(app.riskLevel)}
        <span className="AppCard__size">{app.sizeMB} MB</span>
      </div>

      <i
        className={classNames('fa-solid', 'AppCard__chevron', {
          'fa-chevron-down': !isExpanded,
          'fa-chevron-up': isExpanded,
        })}
      />
    </div>

    {isExpanded && (
      <div className="AppCard__details">
        <div className="AppCard__detail-grid">
          <div className="AppCard__detail-item">
            <i className="fa-solid fa-clock" />
            <div>
              <span className="AppCard__detail-label">Daily Usage</span>
              <span className="AppCard__detail-value">
                {app.dailyUsageMin >= 60
                  ? `${Math.floor(app.dailyUsageMin / 60)}h ${app.dailyUsageMin % 60}m`
                  : `${app.dailyUsageMin}m`}
              </span>
            </div>
          </div>

          <div className="AppCard__detail-item">
            <i className="fa-solid fa-battery-half" />
            <div>
              <span className="AppCard__detail-label">Battery</span>
              <span className="AppCard__detail-value">{app.batteryUsage}%</span>
            </div>
          </div>

          <div className="AppCard__detail-item">
            <i className="fa-solid fa-wifi" />
            <div>
              <span className="AppCard__detail-label">Data Used</span>
              <span className="AppCard__detail-value">
                {app.dataUsageMB >= 1000
                  ? `${(app.dataUsageMB / 1000).toFixed(1)} GB`
                  : `${app.dataUsageMB} MB`}
              </span>
            </div>
          </div>

          <div className="AppCard__detail-item">
            <i className="fa-solid fa-star" />
            <div>
              <span className="AppCard__detail-label">Rating</span>
              <span className="AppCard__detail-value">{app.rating} / 5</span>
            </div>
          </div>

          <div className="AppCard__detail-item">
            <i className="fa-solid fa-history" />
            <div>
              <span className="AppCard__detail-label">Last Used</span>
              <span className="AppCard__detail-value">{app.lastUsed}</span>
            </div>
          </div>

          <div className="AppCard__detail-item">
            <i className="fa-solid fa-database" />
            <div>
              <span className="AppCard__detail-label">App Size</span>
              <span className="AppCard__detail-value">{app.sizeMB} MB</span>
            </div>
          </div>
        </div>

        <div className="AppCard__permissions">
          <h4 className="AppCard__permissions-title">
            <i className="fa-solid fa-lock" /> Permissions (
            {app.permissions.length})
          </h4>
          <div className="AppCard__permissions-list">
            {app.permissions.map(perm => (
              <span
                key={perm}
                className={classNames('tag', 'AppCard__permission-tag', {
                  'is-danger is-light': [
                    'Camera',
                    'Microphone',
                    'Location',
                    'Contacts',
                    'Phone',
                    'SMS',
                  ].includes(perm),
                  'is-warning is-light': [
                    'Clipboard',
                    'Health Data',
                    'Sensors',
                    'Biometrics',
                  ].includes(perm),
                  'is-info is-light': ['Storage', 'Network'].includes(perm),
                })}
              >
                <i className={`fa-solid ${getPermissionIcon(perm)}`} /> {perm}
              </span>
            ))}
          </div>

          {app.permissions.length > 4 && (
            <p className="AppCard__warning has-text-warning">
              <i className="fa-solid fa-triangle-exclamation" /> This app
              requests {app.permissions.length} permissions — more than typical
              for its category
            </p>
          )}
        </div>
      </div>
    )}
  </div>
);
