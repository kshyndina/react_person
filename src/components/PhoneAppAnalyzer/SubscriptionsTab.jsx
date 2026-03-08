import React from 'react';
import classNames from 'classnames';

export const SubscriptionsTab = ({ apps }) => {
  const paidApps = apps.filter(
    a => a.subscription && a.subscription.monthlyCost > 0,
  );
  const freeApps = apps.filter(
    a => !a.subscription || a.subscription.monthlyCost === 0,
  );
  const totalMonthly = paidApps.reduce(
    (sum, a) => sum + a.subscription.monthlyCost,
    0,
  );
  const totalYearly = totalMonthly * 12;

  return (
    <div className="Subscriptions">
      <div className="Subscriptions__overview">
        <div className="Subscriptions__cost-card">
          <i className="fa-solid fa-credit-card" />
          <div>
            <span className="Subscriptions__cost-amount">
              ${totalMonthly.toFixed(2)}
            </span>
            <span className="Subscriptions__cost-label">/ month</span>
          </div>
        </div>

        <div className="Subscriptions__cost-card">
          <i className="fa-solid fa-calendar" />
          <div>
            <span className="Subscriptions__cost-amount">
              ${totalYearly.toFixed(2)}
            </span>
            <span className="Subscriptions__cost-label">/ year</span>
          </div>
        </div>

        <div className="Subscriptions__cost-card">
          <i className="fa-solid fa-receipt" />
          <div>
            <span className="Subscriptions__cost-amount">
              {paidApps.length}
            </span>
            <span className="Subscriptions__cost-label">paid apps</span>
          </div>
        </div>

        <div className="Subscriptions__cost-card">
          <i className="fa-solid fa-gift" />
          <div>
            <span className="Subscriptions__cost-amount">
              {freeApps.length}
            </span>
            <span className="Subscriptions__cost-label">free apps</span>
          </div>
        </div>
      </div>

      <h2 className="Subscriptions__heading">
        <i className="fa-solid fa-credit-card" /> Active Subscriptions
      </h2>

      <div className="Subscriptions__list">
        {paidApps
          .sort(
            (a, b) => b.subscription.monthlyCost - a.subscription.monthlyCost,
          )
          .map(app => (
            <div key={app.id} className="Subscriptions__item">
              <div className="Subscriptions__item-left">
                <div className="AppCard__icon-wrapper">
                  <i
                    className={classNames(
                      app.iconBrand ? 'fa-brands' : 'fa-solid',
                      app.icon,
                      'AppCard__icon',
                    )}
                  />
                </div>
                <div>
                  <strong>{app.name}</strong>
                  <span className="Subscriptions__plan">
                    {app.subscription.plan}
                  </span>
                </div>
              </div>
              <div className="Subscriptions__item-right">
                <span className="Subscriptions__price">
                  ${app.subscription.monthlyCost.toFixed(2)}
                  /mo
                </span>
                {app.subscription.renewDate && (
                  <span className="Subscriptions__renew">
                    Renews {app.subscription.renewDate}
                  </span>
                )}
              </div>
            </div>
          ))}
      </div>

      <h2 className="Subscriptions__heading">
        <i className="fa-solid fa-gift" /> Free Apps
      </h2>
      <div className="Subscriptions__free-list">
        {freeApps.map(app => (
          <span key={app.id} className="tag is-medium is-light">
            <i
              className={classNames(
                app.iconBrand ? 'fa-brands' : 'fa-solid',
                app.icon,
              )}
            />
            &nbsp;{app.name}
            {app.subscription && app.subscription.plan !== 'Free' && (
              <span className="Subscriptions__free-note">
                ({app.subscription.plan})
              </span>
            )}
          </span>
        ))}
      </div>
    </div>
  );
};
