# Sentry Implementation Plan

**Date**: December 9, 2025
**Status**: Approved for Implementation
**Estimated Cost**: $26/month (Team Plan)
**Estimated ROI**: 6,000%+ (based on debugging time savings)

## Executive Summary

Based on comprehensive research from 4 AI sources (GROK, Claude, Gemini, GPT), Sentry integration is **unanimously recommended** to close the critical gap in runtime error monitoring. The current automation stack (CodeRabbit, Semgrep, Gitleaks, Dependabot) catches 30-40% of issues pre-production; Sentry will catch the remaining 60-70% in production.

## Implementation Task List

### Phase 1: Foundation (GitHub Actions + Sentry Setup)

| # | Task | Description | Repository |
|---|------|-------------|------------|
| 1.1 | Create Sentry organization | Sign up at sentry.io, create "fanatico" org | N/A |
| 1.2 | Create Sentry projects | Create projects: fanatico-sites, fanatico-cash, partners-fanati-co | N/A |
| 1.3 | Generate auth tokens | Create SENTRY_AUTH_TOKEN with project:releases scope | N/A |
| 1.4 | Add GitHub secrets | Add SENTRY_AUTH_TOKEN, SENTRY_ORG, SENTRY_PROJECT to each repo | All 3 repos |
| 1.5 | Create sentry-release workflow | Add GitHub Action for release tracking and source map upload | fanatico-sites |
| 1.6 | Create sentry-release workflow | Add GitHub Action for release tracking | fanatico-cash |
| 1.7 | Create sentry-release workflow | Add GitHub Action for release tracking | partners-fanati-co |
| 1.8 | Connect GitHub integration | Link Sentry to GitHub org for suspect commits feature | N/A |
| 1.9 | Verify release tracking | Deploy and confirm releases appear in Sentry | All 3 repos |

### Phase 2: Backend Instrumentation (Node.js/Express)

| # | Task | Description | Repository |
|---|------|-------------|------------|
| 2.1 | Install @sentry/node | Add Sentry SDK to fanatico.me backend | fanatico-sites |
| 2.2 | Configure Sentry init | Add DSN, environment, release config | fanatico-sites |
| 2.3 | Add Express middleware | Setup error handler with setupExpressErrorHandler() | fanatico-sites |
| 2.4 | Install @sentry/node | Add Sentry SDK to Aviator backend | fanatico-cash |
| 2.5 | Configure Sentry init | Add DSN, environment, release config | fanatico-cash |
| 2.6 | Add Express middleware | Setup error handler | fanatico-cash |
| 2.7 | Add Socket.IO wrapper | Manual try-catch instrumentation for Socket.IO events | fanatico-cash |
| 2.8 | Configure PHP SDK | Install sentry/sentry-laravel for partners portal | partners-fanati-co |
| 2.9 | Verify backend errors | Test error capture by triggering test exception | All 3 repos |

### Phase 3: Frontend Instrumentation (React)

| # | Task | Description | Repository |
|---|------|-------------|------------|
| 3.1 | Install @sentry/react | Add Sentry SDK to React frontends | fanatico-sites |
| 3.2 | Configure browser tracing | Add BrowserTracing integration | fanatico-sites |
| 3.3 | Add ErrorBoundary | Wrap app with Sentry.ErrorBoundary | fanatico-sites |
| 3.4 | Configure session replay | Add Replay integration (10% sample, 100% on error) | fanatico-sites |
| 3.5 | Install @sentry/react | Add Sentry SDK to Aviator frontend | fanatico-cash |
| 3.6 | Configure browser tracing | Add BrowserTracing integration | fanatico-cash |
| 3.7 | Add ErrorBoundary | Wrap app with Sentry.ErrorBoundary | fanatico-cash |
| 3.8 | Upload source maps | Configure Vite/webpack for source map generation | Both frontends |
| 3.9 | Verify frontend errors | Test error capture from browser | Both frontends |

### Phase 4: Alerting & Integration

| # | Task | Description | Repository |
|---|------|-------------|------------|
| 4.1 | Configure alert rules | Set up critical error threshold alerts | Sentry |
| 4.2 | Add Slack integration | Connect Sentry to Slack for notifications | Sentry |
| 4.3 | Configure issue ownership | Import CODEOWNERS for auto-assignment | All 3 repos |
| 4.4 | Create custom dashboards | Build dashboards for each service | Sentry |
| 4.5 | Set up PII scrubbing | Configure beforeSend to filter sensitive data | All 3 repos |
| 4.6 | Configure rate limits | Set sampling rates and quota alerts | Sentry |
| 4.7 | Document runbook | Create incident response procedures with Sentry | Documentation |

### Phase 5: Optimization & KPI Tracking

| # | Task | Description | Repository |
|---|------|-------------|------------|
| 5.1 | Baseline KPIs | Record current MTTD, MTTR baselines | Documentation |
| 5.2 | Configure performance monitoring | Enable transaction tracing at 10% sample rate | All 3 repos |
| 5.3 | Set up release health | Configure crash-free session tracking | Sentry |
| 5.4 | Create Grafana integration | Add Sentry metrics to existing Grafana dashboards | Grafana |
| 5.5 | Review and tune | Analyze first month's data, adjust sampling/alerts | Sentry |

## Code Examples

### GitHub Actions Workflow (sentry-release.yml)

```yaml
name: Sentry Release
on:
  push:
    branches: [main]
jobs:
  sentry-release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: getsentry/action-release@v3
        env:
          SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
          SENTRY_ORG: ${{ secrets.SENTRY_ORG }}
          SENTRY_PROJECT: ${{ secrets.SENTRY_PROJECT }}
        with:
          environment: production
          sourcemaps: './dist'
          version: ${{ github.sha }}
```

### Backend Init (Node.js/Express)

```javascript
import * as Sentry from "@sentry/node";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.GIT_COMMIT_SHA,
  tracesSampleRate: 0.1,
  integrations: [
    Sentry.expressIntegration(),
  ],
});

// Express app
app.use(Sentry.expressErrorHandler());
```

### Socket.IO Wrapper (Manual Instrumentation)

```javascript
socket.on("bet", async (data) => {
  try {
    await handleBet(data);
  } catch (error) {
    Sentry.withScope((scope) => {
      scope.setTag("socket.event", "bet");
      scope.setContext("socket", {
        socketId: socket.id,
        userId: socket.userId,
        data
      });
      Sentry.captureException(error);
    });
    socket.emit("error", { message: "Bet failed" });
  }
});
```

### Frontend Init (React)

```javascript
import * as Sentry from "@sentry/react";

Sentry.init({
  dsn: process.env.REACT_APP_SENTRY_DSN,
  environment: process.env.NODE_ENV,
  release: process.env.REACT_APP_GIT_SHA,
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration({
      maskAllText: true,
      blockAllMedia: true,
    }),
  ],
  tracesSampleRate: 0.1,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});

// Wrap App
root.render(
  <Sentry.ErrorBoundary fallback={<ErrorFallback />}>
    <App />
  </Sentry.ErrorBoundary>
);
```

## Target KPIs

| KPI | Target | Measurement |
|-----|--------|-------------|
| Crash-free session rate | >99% | Sentry Release Health |
| Mean Time to Detect (MTTD) | <5 minutes | Error alert timestamp |
| Mean Time to Resolve (MTTR) | 50% reduction | Issue resolution time |
| Bug escape rate | <2% | Production bugs vs pre-prod detection |
| Traceability coverage | 100% | Errors linked to commits |

## Alert Configuration

| Priority | Condition | Cooldown | Destination |
|----------|-----------|----------|-------------|
| Critical | >100 errors in 5 min | 10 min | Slack #incidents |
| High | New issue + high severity | 30 min | Slack #alerts |
| Medium | P95 latency >3s | 1 hour | Slack #performance |
| Low | Error rate >1% sessions | 4 hours | Email digest |

## Cost Analysis

| Item | Monthly Cost |
|------|-------------|
| Sentry Team Plan | $26 |
| **Total New Cost** | **$26/month** |

### ROI Calculation

- **Assumption**: 2 bugs/week, 3 hours debugging without Sentry, 30 min with Sentry
- **Developer hourly rate**: $75
- **Weekly savings**: (2 × 2.5 hours × $75) = $375
- **Annual savings**: $19,500
- **ROI**: 6,250%

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Alert fatigue | Configure thresholds, use percent of sessions |
| Performance overhead | Use 10% trace sampling |
| Cost overrun | Set quota alerts, monitor usage |
| PII exposure | Configure beforeSend filters |
| Vendor lock-in | Standard SDK patterns, exportable data |

## Dependencies

- GitHub secrets configured for SENTRY_AUTH_TOKEN
- Sentry organization created with projects
- Build process generates source maps
- Environment variables for DSN per environment

## Success Criteria

1. All production errors captured in Sentry within 1 minute
2. 100% of errors linked to suspect commits
3. MTTD reduced to <5 minutes
4. Crash-free session rate >99%
5. Team actively triaging Sentry issues

## Timeline

| Phase | Duration | Status |
|-------|----------|--------|
| Phase 1: Foundation | 2-3 days | Pending |
| Phase 2: Backend | 3-4 days | Pending |
| Phase 3: Frontend | 3-4 days | Pending |
| Phase 4: Alerting | 2-3 days | Pending |
| Phase 5: Optimization | Ongoing | Pending |

**Total Initial Setup**: ~2 weeks

## Related Documentation

- `/home/sebastian/git-repos/fanatico-documentation/AI-CODING/CODE_REVIEW_AUTOMATION_STATE.md`
- `/home/sebastian/git-repos/fanatico-documentation/SECURITY/PHASE2_SECURITY_HARDENING.md`
- `/home/sebastian/git-repos/fanatico-documentation/AI-CODING/PHASE3_DEVELOPMENT_ACCELERATION.md`

## Research Sources

- GROK-Sentry-Research.pdf
- Claude-Sentry-Research.md
- Gemini-Sentry-Research.md
- GPT-Sentry-Research.pdf

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2025-12-09 | Initial implementation plan created from AI research synthesis | Claude |

---

**Approval**: Pending
**Owner**: Development Team
**Review Date**: December 2025
