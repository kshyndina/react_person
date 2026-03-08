import React, { useState } from 'react';
import classNames from 'classnames';

export const AppManagerTab = ({
  apps,
  deletedApps,
  onDeleteApp,
  onRestoreApp,
}) => {
  const [confirmId, setConfirmId] = useState(null);

  const activeApps = apps.filter(a => !deletedApps.includes(a.id));
  const removed = apps.filter(a => deletedApps.includes(a.id));

  const totalSaved = removed.reduce((s, a) => s + a.sizeMB, 0);

  const handleDelete = id => {
    onDeleteApp(id);
    setConfirmId(null);
  };

  return (
    <div className="AppManager">
      {removed.length > 0 && (
        <div className="Dashboard__alert Dashboard__alert--info">
          <h3>
            <i className="fa-solid fa-trash-can" /> {removed.length} app(s)
            removed &mdash; {totalSaved} MB freed
          </h3>
          <p>
            Removed apps are listed below. You can restore them at any time.
          </p>
        </div>
      )}

      <h2 className="AppManager__heading">
        <i className="fa-solid fa-mobile-screen" /> Installed Apps (
        {activeApps.length})
      </h2>

      <div className="AppManager__list">
        {activeApps.map(app => (
          <div key={app.id} className="AppManager__row">
            <div className="AppManager__row-left">
              <div className="AppCard__icon-wrapper">
                <i
                  className={classNames(
                    app.iconBrand ? 'fa-brands' : 'fa-solid',
                    app.icon,
                    'AppCard__icon',
                  )}
                />
              </div>
              <div className="AppManager__app-info">
                <strong>{app.name}</strong>
                <span className="AppManager__meta">
                  {app.sizeMB} MB &middot; {app.category}
                </span>
              </div>
            </div>

            <div className="AppManager__row-right">
              {confirmId === app.id ? (
                <div className="AppManager__confirm">
                  <span>Delete {app.name}?</span>
                  <button
                    type="button"
                    className="button is-danger is-small"
                    onClick={() => handleDelete(app.id)}
                  >
                    Yes, Delete
                  </button>
                  <button
                    type="button"
                    className="button is-light is-small"
                    onClick={() => setConfirmId(null)}
                  >
                    Cancel
                  </button>
                </div>
              ) : (
                <button
                  type="button"
                  className="button is-danger is-outlined is-small"
                  onClick={() => setConfirmId(app.id)}
                >
                  <span className="icon is-small">
                    <i className="fa-solid fa-trash" />
                  </span>
                  <span>Uninstall</span>
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {removed.length > 0 && (
        <>
          <h2 className="AppManager__heading">
            <i className="fa-solid fa-clock-rotate-left" /> Recently Removed
          </h2>

          <div className="AppManager__list">
            {removed.map(app => (
              <div
                key={app.id}
                className="AppManager__row AppManager__row--deleted"
              >
                <div className="AppManager__row-left">
                  <div className="AppCard__icon-wrapper">
                    <i
                      className={classNames(
                        app.iconBrand ? 'fa-brands' : 'fa-solid',
                        app.icon,
                        'AppCard__icon',
                      )}
                    />
                  </div>
                  <div className="AppManager__app-info">
                    <strong>{app.name}</strong>
                    <span className="AppManager__meta">
                      {app.sizeMB} MB &middot; {app.category}
                    </span>
                  </div>
                </div>

                <button
                  type="button"
                  className="button is-info is-outlined is-small"
                  onClick={() => onRestoreApp(app.id)}
                >
                  <span className="icon is-small">
                    <i className="fa-solid fa-rotate-left" />
                  </span>
                  <span>Reinstall</span>
                </button>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  );
};
