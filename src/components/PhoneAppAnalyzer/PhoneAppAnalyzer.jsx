import React, { useState, useMemo } from 'react';
import { phoneApps } from '../../data/phoneApps';
import { AppCard } from './AppCard';
import { AnalysisDashboard } from './AnalysisDashboard';
import { SubscriptionsTab } from './SubscriptionsTab';
import { AppManagerTab } from './AppManagerTab';
import { SettingsTab } from './SettingsTab';
import './PhoneAppAnalyzer.scss';

const SORT_OPTIONS = {
  name: (a, b) => a.name.localeCompare(b.name),
  size: (a, b) => b.sizeMB - a.sizeMB,
  usage: (a, b) => b.dailyUsageMin - a.dailyUsageMin,
  battery: (a, b) => b.batteryUsage - a.batteryUsage,
  data: (a, b) => b.dataUsageMB - a.dataUsageMB,
  risk: (a, b) => {
    const order = { high: 0, medium: 1, low: 2 };

    return order[a.riskLevel] - order[b.riskLevel];
  },
};

const TABS = [
  {
    id: 'dashboard',
    label: 'Dashboard',
    icon: 'fa-chart-pie',
  },
  {
    id: 'apps',
    label: 'All Apps',
    icon: 'fa-grip',
  },
  {
    id: 'subscriptions',
    label: 'Subscriptions',
    icon: 'fa-credit-card',
  },
  {
    id: 'manage',
    label: 'Manage',
    icon: 'fa-trash-can',
  },
  {
    id: 'privacy',
    label: 'Privacy',
    icon: 'fa-shield-halved',
  },
  {
    id: 'settings',
    label: 'Settings',
    icon: 'fa-gear',
  },
];

export const PhoneAppAnalyzer = () => {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('All');
  const [sortBy, setSortBy] = useState('name');
  const [expandedApp, setExpandedApp] = useState(null);
  const [scanning, setScanning] = useState(false);
  const [scanned, setScanned] = useState(false);
  const [deletedApps, setDeletedApps] = useState([]);

  const categories = useMemo(() => {
    const cats = [...new Set(phoneApps.map(app => app.category))].sort();

    return ['All', ...cats];
  }, []);

  const filteredApps = useMemo(() => {
    let result = [...phoneApps].filter(a => !deletedApps.includes(a.id));

    if (searchQuery) {
      const q = searchQuery.toLowerCase();

      result = result.filter(
        app =>
          app.name.toLowerCase().includes(q) ||
          app.category.toLowerCase().includes(q),
      );
    }

    if (selectedCategory !== 'All') {
      result = result.filter(app => app.category === selectedCategory);
    }

    result.sort(SORT_OPTIONS[sortBy]);

    return result;
  }, [searchQuery, selectedCategory, sortBy, deletedApps]);

  const handleScan = () => {
    setScanning(true);
    setTimeout(() => {
      setScanning(false);
      setScanned(true);
    }, 2500);
  };

  const handleDeleteApp = id => {
    setDeletedApps(prev => [...prev, id]);
  };

  const handleRestoreApp = id => {
    setDeletedApps(prev => prev.filter(x => x !== id));
  };

  if (!scanned) {
    return (
      <div className="PhoneAppAnalyzer">
        <div className="PhoneAppAnalyzer__welcome">
          <div className="PhoneAppAnalyzer__phone-frame">
            <div className="PhoneAppAnalyzer__phone-notch" />
            <div className="PhoneAppAnalyzer__phone-screen">
              <i
                className={
                  'fa-solid' +
                  ' fa-mobile-screen-button' +
                  ' PhoneAppAnalyzer__welcome-icon'
                }
              />
              <h1 className="PhoneAppAnalyzer__welcome-title">
                Phone App Analyzer
              </h1>
              <p className="PhoneAppAnalyzer__welcome-text">
                Scan your device to analyze installed apps, subscriptions,
                permissions, and phone settings.
              </p>

              {scanning ? (
                <div className="PhoneAppAnalyzer__scanning">
                  <div className="PhoneAppAnalyzer__scan-ring" />
                  <p>Scanning {phoneApps.length} apps...</p>
                  <progress className="progress is-info" max="100">
                    Scanning
                  </progress>
                </div>
              ) : (
                <button
                  type="button"
                  className="button is-info is-large PhoneAppAnalyzer__scan-btn"
                  onClick={handleScan}
                >
                  <span className="icon">
                    <i className="fa-solid fa-magnifying-glass" />
                  </span>
                  <span>Scan My Phone</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="PhoneAppAnalyzer">
      <header className="PhoneAppAnalyzer__header">
        <div className="PhoneAppAnalyzer__title-row">
          <h1 className="PhoneAppAnalyzer__title">
            <i className="fa-solid fa-mobile-screen-button" /> Phone App
            Analyzer
          </h1>
          <span className="tag is-info is-medium">
            {phoneApps.length - deletedApps.length} apps
          </span>
        </div>

        <div className="tabs is-centered is-boxed PhoneAppAnalyzer__tabs">
          <ul>
            {TABS.map(tab => (
              <li
                key={tab.id}
                className={activeTab === tab.id ? 'is-active' : ''}
              >
                <button
                  type="button"
                  className="PhoneAppAnalyzer__tab-btn"
                  onClick={() => setActiveTab(tab.id)}
                >
                  <span className="icon">
                    <i className={`fa-solid ${tab.icon}`} />
                  </span>
                  <span>{tab.label}</span>
                </button>
              </li>
            ))}
          </ul>
        </div>
      </header>

      <main className="PhoneAppAnalyzer__content">
        {activeTab === 'dashboard' && <AnalysisDashboard apps={phoneApps} />}

        {activeTab === 'apps' && (
          <div className="PhoneAppAnalyzer__apps-view">
            <div className="PhoneAppAnalyzer__controls">
              <div className="field has-addons PhoneAppAnalyzer__search">
                <div className="control has-icons-left is-expanded">
                  <input
                    className="input"
                    type="text"
                    placeholder="Search apps..."
                    value={searchQuery}
                    onChange={e => setSearchQuery(e.target.value)}
                  />
                  <span className="icon is-left">
                    <i className="fa-solid fa-magnifying-glass" />
                  </span>
                </div>
              </div>

              <div className="field PhoneAppAnalyzer__filter">
                <div className="control">
                  <div className="select">
                    <select
                      value={selectedCategory}
                      onChange={e => setSelectedCategory(e.target.value)}
                    >
                      {categories.map(cat => (
                        <option key={cat} value={cat}>
                          {cat}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>

              <div className="field PhoneAppAnalyzer__sort">
                <div className="control">
                  <div className="select">
                    <select
                      value={sortBy}
                      onChange={e => setSortBy(e.target.value)}
                    >
                      <option value="name">Sort: Name</option>
                      <option value="size">Sort: Size</option>
                      <option value="usage">Sort: Screen Time</option>
                      <option value="battery">Sort: Battery</option>
                      <option value="data">Sort: Data Usage</option>
                      <option value="risk">Sort: Risk Level</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            <p className="PhoneAppAnalyzer__results-count">
              Showing {filteredApps.length} of{' '}
              {phoneApps.length - deletedApps.length} apps
            </p>

            <div className="PhoneAppAnalyzer__app-list">
              {filteredApps.map(app => (
                <AppCard
                  key={app.id}
                  app={app}
                  isExpanded={expandedApp === app.id}
                  onToggle={() =>
                    setExpandedApp(expandedApp === app.id ? null : app.id)
                  }
                />
              ))}

              {filteredApps.length === 0 && (
                <div className="PhoneAppAnalyzer__empty">
                  <i className="fa-solid fa-magnifying-glass" />
                  <p>No apps match your search</p>
                </div>
              )}
            </div>
          </div>
        )}

        {activeTab === 'subscriptions' && <SubscriptionsTab apps={phoneApps} />}

        {activeTab === 'manage' && (
          <AppManagerTab
            apps={phoneApps}
            deletedApps={deletedApps}
            onDeleteApp={handleDeleteApp}
            onRestoreApp={handleRestoreApp}
          />
        )}

        {activeTab === 'privacy' && (
          <div className="PhoneAppAnalyzer__privacy">
            <div className="Dashboard__alert Dashboard__alert--info">
              <h3>
                <i className="fa-solid fa-shield-halved" /> Privacy Score:{' '}
                {Math.round(
                  100 -
                    phoneApps.reduce(
                      (sum, a) => sum + a.permissions.length * 2,
                      0,
                    ) /
                      phoneApps.length,
                )}
                /100
              </h3>
              <p>Based on permissions requested by your installed apps.</p>
            </div>

            <h2 className="PhoneAppAnalyzer__section-title">
              <i className="fa-solid fa-triangle-exclamation" /> Apps with
              Excessive Permissions
            </h2>
            {phoneApps
              .filter(a => a.permissions.length > 4)
              .sort((a, b) => b.permissions.length - a.permissions.length)
              .map(app => (
                <div key={app.id} className="PhoneAppAnalyzer__privacy-card">
                  <div className="PhoneAppAnalyzer__privacy-header">
                    <strong>{app.name}</strong>
                    <span className="tag is-warning">
                      {app.permissions.length} permissions
                    </span>
                  </div>
                  <div className="PhoneAppAnalyzer__privacy-perms">
                    {app.permissions.map(p => (
                      <span key={p} className="tag is-light">
                        {p}
                      </span>
                    ))}
                  </div>
                  <p className="PhoneAppAnalyzer__privacy-tip">
                    {app.riskLevel === 'high' ? (
                      <span className="has-text-danger">
                        <i className="fa-solid fa-circle-exclamation" />{' '}
                        Recommend removing or restricting permissions
                      </span>
                    ) : (
                      <span className="has-text-warning-dark">
                        <i className="fa-solid fa-info-circle" /> Review if all
                        permissions are necessary
                      </span>
                    )}
                  </p>
                </div>
              ))}

            <h2 className="PhoneAppAnalyzer__section-title">
              <i className="fa-solid fa-location-dot" /> Location-Tracking Apps
            </h2>
            <div className="PhoneAppAnalyzer__location-list">
              {phoneApps
                .filter(a => a.permissions.includes('Location'))
                .map(app => {
                  const cls = 'tag is-medium is-light';

                  return (
                    <span key={app.id} className={cls}>
                      <i className="fa-solid fa-location-dot has-text-danger" />
                      &nbsp;{app.name}
                    </span>
                  );
                })}
            </div>

            <h2 className="PhoneAppAnalyzer__section-title">
              <i className="fa-solid fa-microphone" /> Microphone Access Apps
            </h2>
            <div className="PhoneAppAnalyzer__location-list">
              {phoneApps
                .filter(a => a.permissions.includes('Microphone'))
                .map(app => (
                  <span key={app.id} className="tag is-medium is-light">
                    <i className="fa-solid fa-microphone has-text-info" />{' '}
                    &nbsp;{app.name}
                  </span>
                ))}
            </div>
          </div>
        )}

        {activeTab === 'settings' && <SettingsTab />}
      </main>

      <footer className="PhoneAppAnalyzer__footer">
        <p>
          <i className="fa-solid fa-circle-info" /> This analysis is based on
          simulated app data for demonstration purposes.
        </p>
      </footer>
    </div>
  );
};
