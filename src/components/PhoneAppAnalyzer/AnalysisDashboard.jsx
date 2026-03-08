import React from 'react';

const BarChart = ({ items, maxValue, colorClass }) => (
  <div className="BarChart">
    {items.map(item => (
      <div key={item.label} className="BarChart__row">
        <span className="BarChart__label">{item.label}</span>
        <div className="BarChart__bar-wrapper">
          <div
            className={`BarChart__bar ${colorClass}`}
            style={{ width: `${(item.value / maxValue) * 100}%` }}
          />
        </div>
        <span className="BarChart__value">{item.display || item.value}</span>
      </div>
    ))}
  </div>
);

export const AnalysisDashboard = ({ apps }) => {
  const totalStorage = apps.reduce((sum, app) => sum + app.sizeMB, 0);
  const totalDataUsage = apps.reduce((sum, app) => sum + app.dataUsageMB, 0);
  const totalBattery = apps.reduce((sum, app) => sum + app.batteryUsage, 0);
  const totalDailyMinutes = apps.reduce(
    (sum, app) => sum + app.dailyUsageMin,
    0,
  );

  const highRiskApps = apps.filter(a => a.riskLevel === 'high');
  const medRiskApps = apps.filter(a => a.riskLevel === 'medium');

  const categoryCount = {};

  apps.forEach(app => {
    categoryCount[app.category] = (categoryCount[app.category] || 0) + 1;
  });

  const topByUsage = [...apps]
    .sort((a, b) => b.dailyUsageMin - a.dailyUsageMin)
    .slice(0, 5);

  const topByBattery = [...apps]
    .sort((a, b) => b.batteryUsage - a.batteryUsage)
    .slice(0, 5);

  const topByData = [...apps]
    .sort((a, b) => b.dataUsageMB - a.dataUsageMB)
    .slice(0, 5);

  const topBySize = [...apps].sort((a, b) => b.sizeMB - a.sizeMB).slice(0, 5);

  const allPerms = {};

  apps.forEach(app => {
    app.permissions.forEach(p => {
      allPerms[p] = (allPerms[p] || 0) + 1;
    });
  });

  const permEntries = Object.entries(allPerms).sort((a, b) => b[1] - a[1]);

  return (
    <div className="Dashboard">
      <div className="Dashboard__summary">
        <div className="Dashboard__stat-card Dashboard__stat-card--apps">
          <i className="fa-solid fa-mobile-screen-button" />
          <div>
            <span className="Dashboard__stat-number">{apps.length}</span>
            <span className="Dashboard__stat-label">Apps Installed</span>
          </div>
        </div>

        <div className="Dashboard__stat-card Dashboard__stat-card--storage">
          <i className="fa-solid fa-database" />
          <div>
            <span className="Dashboard__stat-number">
              {(totalStorage / 1000).toFixed(1)} GB
            </span>
            <span className="Dashboard__stat-label">Total Storage</span>
          </div>
        </div>

        <div className="Dashboard__stat-card Dashboard__stat-card--time">
          <i className="fa-solid fa-clock" />
          <div>
            <span className="Dashboard__stat-number">
              {Math.floor(totalDailyMinutes / 60)}h {totalDailyMinutes % 60}m
            </span>
            <span className="Dashboard__stat-label">Daily Screen Time</span>
          </div>
        </div>

        <div className="Dashboard__stat-card Dashboard__stat-card--battery">
          <i className="fa-solid fa-battery-half" />
          <div>
            <span className="Dashboard__stat-number">{totalBattery}%</span>
            <span className="Dashboard__stat-label">Battery Drain</span>
          </div>
        </div>

        <div className="Dashboard__stat-card Dashboard__stat-card--data">
          <i className="fa-solid fa-wifi" />
          <div>
            <span className="Dashboard__stat-number">
              {(totalDataUsage / 1000).toFixed(1)} GB
            </span>
            <span className="Dashboard__stat-label">Data Used</span>
          </div>
        </div>

        <div className="Dashboard__stat-card Dashboard__stat-card--risk">
          <i className="fa-solid fa-shield-halved" />
          <div>
            <span className="Dashboard__stat-number">
              {highRiskApps.length}
            </span>
            <span className="Dashboard__stat-label">High Risk Apps</span>
          </div>
        </div>
      </div>

      {highRiskApps.length > 0 && (
        <div className="Dashboard__alert Dashboard__alert--danger">
          <h3>
            <i className="fa-solid fa-circle-exclamation" /> Security Alerts
          </h3>
          {highRiskApps.map(app => (
            <p key={app.id}>
              <strong>{app.name}</strong> requests {app.permissions.length}{' '}
              permissions — excessive for a {app.category.toLowerCase()} app.
              Consider uninstalling or restricting permissions.
            </p>
          ))}
        </div>
      )}

      {medRiskApps.length > 0 && (
        <div className="Dashboard__alert Dashboard__alert--warning">
          <h3>
            <i className="fa-solid fa-triangle-exclamation" /> Privacy Warnings
          </h3>
          <p>
            {medRiskApps.length} app(s) have elevated permission requests:{' '}
            {medRiskApps.map(a => a.name).join(', ')}
          </p>
        </div>
      )}

      <div className="Dashboard__charts">
        <div className="Dashboard__chart-card">
          <h3>
            <i className="fa-solid fa-clock" /> Top Apps by Screen Time
          </h3>
          <BarChart
            items={topByUsage.map(a => ({
              label: a.name,
              value: a.dailyUsageMin,
              display:
                a.dailyUsageMin >= 60
                  ? `${Math.floor(a.dailyUsageMin / 60)}h ${a.dailyUsageMin % 60}m`
                  : `${a.dailyUsageMin}m`,
            }))}
            maxValue={Math.max(...topByUsage.map(a => a.dailyUsageMin))}
            colorClass="BarChart__bar--blue"
          />
        </div>

        <div className="Dashboard__chart-card">
          <h3>
            <i className="fa-solid fa-battery-half" /> Top Battery Drainers
          </h3>
          <BarChart
            items={topByBattery.map(a => ({
              label: a.name,
              value: a.batteryUsage,
              display: `${a.batteryUsage}%`,
            }))}
            maxValue={Math.max(...topByBattery.map(a => a.batteryUsage))}
            colorClass="BarChart__bar--red"
          />
        </div>

        <div className="Dashboard__chart-card">
          <h3>
            <i className="fa-solid fa-wifi" /> Top Data Consumers
          </h3>
          <BarChart
            items={topByData.map(a => ({
              label: a.name,
              value: a.dataUsageMB,
              display:
                a.dataUsageMB >= 1000
                  ? `${(a.dataUsageMB / 1000).toFixed(1)} GB`
                  : `${a.dataUsageMB} MB`,
            }))}
            maxValue={Math.max(...topByData.map(a => a.dataUsageMB))}
            colorClass="BarChart__bar--green"
          />
        </div>

        <div className="Dashboard__chart-card">
          <h3>
            <i className="fa-solid fa-database" /> Largest Apps by Size
          </h3>
          <BarChart
            items={topBySize.map(a => ({
              label: a.name,
              value: a.sizeMB,
              display: `${a.sizeMB} MB`,
            }))}
            maxValue={Math.max(...topBySize.map(a => a.sizeMB))}
            colorClass="BarChart__bar--purple"
          />
        </div>
      </div>

      <div className="Dashboard__chart-card">
        <h3>
          <i className="fa-solid fa-lock" /> Most Requested Permissions
        </h3>
        <BarChart
          items={permEntries.map(([perm, count]) => ({
            label: perm,
            value: count,
            display: `${count} apps`,
          }))}
          maxValue={Math.max(...permEntries.map(([, c]) => c))}
          colorClass="BarChart__bar--orange"
        />
      </div>

      <div className="Dashboard__chart-card">
        <h3>
          <i className="fa-solid fa-folder" /> Apps by Category
        </h3>
        <div className="Dashboard__categories">
          {Object.entries(categoryCount)
            .sort((a, b) => b[1] - a[1])
            .map(([cat, count]) => (
              <div key={cat} className="Dashboard__category-badge">
                <span className="Dashboard__category-name">{cat}</span>
                <span className="tag is-info is-rounded">{count}</span>
              </div>
            ))}
        </div>
      </div>
    </div>
  );
};
